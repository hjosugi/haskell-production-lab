module Main (main) where

import Control.Exception (bracket, bracket_)
import Control.Monad (void)
import Data.Aeson (Value (String))
import qualified Data.ByteString.Char8 as BS8
import qualified Data.Map.Strict as Map
import Data.Pool (defaultPoolConfig, destroyAllResources, newPool, withResource)
import Data.String (fromString)
import qualified Data.Text as T
import Database.PostgreSQL.Simple (close, connectPostgreSQL, execute_)
import HPS.Ledger
import HPS.Service.KV (Handle (..))
import HPS.Service.KV.Postgres (decodeJsonbValue, encodeJsonbValue, newPostgresHandle)
import HPS.StaticSite
import HPS.Util
import System.Environment (lookupEnv)

main :: IO ()
main = do
  assert "slugify basic" (slugify "Hello, Haskell Service!" == "hello-haskell-service")
  assert "stable slug is total" (stableSlug "Typed calculator-2" == "typed-calculator-2-33694dea")
  assert "markdown h1" ("<h1>Hello</h1>" `T.isInfixOf` markdownToHtml "# Hello")
  case parseLedgerLine "sale; cash:100; revenue:-100" of
    Right _ -> pure ()
    Left err -> fail ("ledger parse failed: " <> show err)
  testPostgresJsonbCodec
  lookupEnv "HPS_TEST_DATABASE_URL" >>= \case
    Nothing -> putStrLn "PostgreSQL integration test skipped (HPS_TEST_DATABASE_URL is unset)"
    Just databaseUrl -> testPostgresHandle databaseUrl
  putStrLn "hps-test passed"

testPostgresJsonbCodec :: IO ()
testPostgresJsonbCodec = do
  let payload =
        Map.fromList
          [ ("numbers", [1, 2, 3])
          , ("empty", [])
          ] ::
          Map.Map T.Text [Int]
      roundTrip = decodeJsonbValue (encodeJsonbValue payload)
  assert "PostgreSQL JSONB codec round trip" (roundTrip == Right payload)
  case decodeJsonbValue (String "wrong shape") :: Either String (Map.Map T.Text [Int]) of
    Left _ -> pure ()
    Right _ -> fail "PostgreSQL JSONB codec accepted an invalid value shape"

testPostgresHandle :: String -> IO ()
testPostgresHandle databaseUrl =
  bracket_ prepareSchema dropSchema $
    bracket createPool destroyAllResources \pool -> do
      migration <- readFile "migrations/postgresql/0001_hps_kv.sql"
      withResource pool \connection ->
        void $ execute_ connection (fromString migration)

      let firstValue = Map.fromList [("numbers", [1, 2, 3])] :: Map.Map T.Text [Int]
          secondValue = Map.fromList [("numbers", [8, 13])] :: Map.Map T.Text [Int]
          store = newPostgresHandle pool :: Handle T.Text (Map.Map T.Text [Int])

      kvPut store "beta" secondValue
      kvPut store "alpha" firstValue
      fetched <- kvGet store "alpha"
      assert "PostgreSQL kvGet returns JSONB value" (fetched == Just firstValue)

      listed <- kvList store
      assert
        "PostgreSQL kvList is key ordered"
        (listed == [("alpha", firstValue), ("beta", secondValue)])

      kvPut store "alpha" secondValue
      updated <- kvGet store "alpha"
      assert "PostgreSQL kvPut updates an existing key" (updated == Just secondValue)

      kvDelete store "alpha"
      deleted <- kvGet store "alpha"
      assert "PostgreSQL kvDelete removes a key" (deleted == Nothing)
 where
  connectionString = BS8.pack databaseUrl

  withAdminConnection action =
    bracket (connectPostgreSQL connectionString) close action

  prepareSchema = withAdminConnection \connection -> do
    void $ execute_ connection "CREATE SCHEMA hps_kv_integration_test"

  dropSchema = withAdminConnection \connection ->
    void $ execute_ connection "DROP SCHEMA IF EXISTS hps_kv_integration_test CASCADE"

  createConnection = do
    connection <- connectPostgreSQL connectionString
    void $ execute_ connection "SET search_path TO hps_kv_integration_test"
    pure connection

  createPool = newPool (defaultPoolConfig createConnection close 30 1)

assert :: String -> Bool -> IO ()
assert name ok = if ok then pure () else fail name
