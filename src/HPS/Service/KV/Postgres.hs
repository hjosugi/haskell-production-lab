module HPS.Service.KV.Postgres (
  PostgresKVError (..),
  newPostgresHandle,
  encodeJsonbValue,
  decodeJsonbValue,
) where

import Control.Exception (Exception, throwIO)
import Control.Monad (void)
import Data.Aeson (FromJSON, Result (..), ToJSON, Value, fromJSON, toJSON)
import Data.Pool (Pool, withResource)
import Data.Text (Text)
import Database.PostgreSQL.Simple (
  Connection,
  Only (..),
  execute,
  query,
  query_,
 )
import HPS.Service.KV (Handle (..))

-- | A stored JSON value did not match the value type requested by the caller.
--
-- PostgreSQL and pool errors are deliberately left as their original exception
-- types so callers can inspect SQLSTATE values and apply their own retry policy.
data PostgresKVError = PostgresKVDecodeError
  { postgresKVKey :: Text
  , postgresKVMessage :: String
  }
  deriving stock (Eq, Show)

instance Exception PostgresKVError

-- | Encode an application value at the adapter's JSONB boundary.
encodeJsonbValue :: (ToJSON v) => v -> Value
encodeJsonbValue = toJSON

-- | Decode an application value at the adapter's JSONB boundary.
decodeJsonbValue :: (FromJSON v) => Value -> Either String v
decodeJsonbValue value = case fromJSON value of
  Error message -> Left message
  Success decoded -> Right decoded

-- | Back a key-value handle with the @hps_kv@ PostgreSQL table.
--
-- Apply @migrations/postgresql/0001_hps_kv.sql@ before using the handle. Each
-- operation checks out one connection, and each put/delete is one atomic SQL
-- statement. The caller owns the pool and its lifecycle.
newPostgresHandle :: forall v. (FromJSON v, ToJSON v) => Pool Connection -> Handle Text v
newPostgresHandle pool =
  Handle
    { kvGet = getValue
    , kvPut = putValue
    , kvDelete = deleteValue
    , kvList = listValues
    }
 where
  getValue :: Text -> IO (Maybe v)
  getValue key = do
    rows <- withResource pool \connection ->
      query
        connection
        "SELECT kv_value FROM hps_kv WHERE kv_key = ?"
        (Only key) ::
        IO [Only Value]
    case rows of
      [] -> pure Nothing
      Only rawValue : _ -> Just <$> decodeStoredValue key rawValue

  putValue :: Text -> v -> IO ()
  putValue key value = withResource pool \connection ->
    void $
      execute
        connection
        "INSERT INTO hps_kv (kv_key, kv_value) VALUES (?, ?::jsonb) \
        \ON CONFLICT (kv_key) DO UPDATE \
        \SET kv_value = EXCLUDED.kv_value, updated_at = CURRENT_TIMESTAMP"
        (key, encodeJsonbValue value)

  deleteValue :: Text -> IO ()
  deleteValue key = withResource pool \connection ->
    void $
      execute
        connection
        "DELETE FROM hps_kv WHERE kv_key = ?"
        (Only key)

  listValues :: IO [(Text, v)]
  listValues = do
    rows <- withResource pool \connection ->
      query_
        connection
        "SELECT kv_key, kv_value FROM hps_kv ORDER BY kv_key" ::
        IO [(Text, Value)]
    traverse decodeRow rows

  decodeRow :: (Text, Value) -> IO (Text, v)
  decodeRow (key, rawValue) = do
    value <- decodeStoredValue key rawValue
    pure (key, value)

decodeStoredValue :: (FromJSON v) => Text -> Value -> IO v
decodeStoredValue key rawValue = case decodeJsonbValue rawValue of
  Left message ->
    throwIO
      PostgresKVDecodeError
        { postgresKVKey = key
        , postgresKVMessage = message
        }
  Right value -> pure value
