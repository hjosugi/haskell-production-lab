module HPS.Ledger
  ( newTransaction
  , balances
  , renderBalances
  , parseLedgerLine
  ) where

import Data.List (foldl')
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import Data.Text (Text)
import qualified Data.Text as T
import Data.Time (UTCTime)
import HPS.Domain
import HPS.Util (tshow)
import HPS.Validation (validateLedgerSeed)

newTransaction :: UTCTime -> Text -> LedgerSeed -> Either Text LedgerTransaction
newTransaction now ident seed@LedgerSeed{ledgerDescriptionSeed, ledgerPostingsSeed} = do
  validateLedgerSeed seed
  pure LedgerTransaction
    { ledgerId = ident
    , ledgerDescription = ledgerDescriptionSeed
    , ledgerPostings = ledgerPostingsSeed
    , ledgerCreatedAt = now
    }

balances :: [LedgerTransaction] -> [Balance]
balances txs = map (uncurry Balance) (Map.toList result)
  where
    result :: Map Text Double
    result = foldl' addTx Map.empty txs
    addTx acc tx = foldl' addPosting acc (ledgerPostings tx)
    addPosting acc LedgerPosting{postingAccount, postingAmount} =
      Map.insertWith (+) postingAccount postingAmount acc

renderBalances :: [Balance] -> Text
renderBalances bs = T.unlines ("account,amount" : map render bs)
  where
    render Balance{balanceAccount, balanceAmount} = balanceAccount <> "," <> tshow balanceAmount

-- | Parse a tiny journal line: "description; account:+10; other:-10".
parseLedgerLine :: Text -> Either Text LedgerSeed
parseLedgerLine raw =
  case T.splitOn ";" raw of
    [] -> Left "empty ledger line"
    (description:postingTexts) -> do
      postings <- traverse parsePosting postingTexts
      pure LedgerSeed
        { ledgerDescriptionSeed = T.strip description
        , ledgerPostingsSeed = postings
        }
  where
    parsePosting part =
      case T.splitOn ":" (T.strip part) of
        [account, amountText] ->
          case reads (T.unpack (T.strip amountText)) of
            [(amount, "")] -> Right LedgerPosting{postingAccount = T.strip account, postingAmount = amount}
            _ -> Left ("invalid amount: " <> amountText)
        _ -> Left ("invalid posting: " <> part)
