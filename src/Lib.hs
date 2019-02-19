module Lib
    ( someFunc
    ) where

import App
import qualified Data.Convertible.Base as Convertible
import qualified Database.HDBC as HDBC


someFunc :: IO ()
someFunc = runHaskETL $
  liftIO $ putStrLn "someFunc"

-- TODO:
-- - Make Row a typeclass instead, since we will have many types of Rows
-- - Generically convert regular Rows to specific Rows and Tables (e.g. Row ->
-- DatacenterRow, Row -> ServerRow, ...)
data Row = Row [ HDBC.SqlValue ] deriving Show

data DatacenterTable = DatacenterTable [ DatacenterRow ]
-- example row in datacenter table: datacenter ID, datacenter abbreviation,
-- ticket queue ID
data DatacenterRow = DatacenterRow Int String Int

-- TODO make this a generic fn elevating a Row to a specific type of Row
toDatacenterRow :: Row -> Convertible.ConvertResult DatacenterRow
toDatacenterRow (Row [dcID, abbr, qID]) = DatacenterRow
  <$> HDBC.safeFromSql dcID
  <*> HDBC.safeFromSql abbr
  <*> HDBC.safeFromSql qID
toDatacenterRow r = Convertible.convError "Could not parse a datacenter row" r

sqlValueToRow :: Maybe [HDBC.SqlValue] -> Maybe Row
sqlValueToRow v = Row <$> v
{-
 - General program flow:
 - - (Possibly) Execute SQL against MSSQL DB from types we define
 - - Reason: We can run limited versions of these queries to test whether they
 - will work.
 - - Note: The above may involve some more complex logic, like joins, filtering
 - out account banlists, etc.
 - - Run series of postprocessing steps in BigQuery to generate further tables
 - - Run tests against those tables validating they meet our assumptions (table
 - unchanged, only rows added, etc.)
 -}

{- HDBC Notes
- HDBC can read from SQL server on-demand, so you don't have to pull in the
- entire result se. This could be good for testing.
-
- SqlValue type is not usually manipulated directly. Instead, use toSql and
- fromSql (or safeFromSql) on SqlValues to convert to and from Haskell types.
-
- safeFromSql uses standard Left/Right for error handling, regular fromSql
- uses exceptions
-
- careful with timezones/timestamps, there's some oddness depending on your
- DB
-
- safeFromSql returns a ConvertResult a
-
- <only skimming the connection section since this will not impact core
- application logic>
-
- query execution:
- https://www.stackage.org/haddock/lts-13.8/HDBC-2.4.0.2/Database-HDBC.html#g:7
-
- "prepare" will take a connection, a string, and give you an IO Statement
- question marks in the Statement will be replaced by positional parameters
- later (query interpolation, to avoid injection or otherwise have variable
- values - we can likely use this for constants like an account banlist)
-
- result fetching
- https://www.stackage.org/haddock/lts-13.8/HDBC-2.4.0.2/Database-HDBC.html#g:12
- fetchAllRows will lazily pull from the result set, like hGetContents
- can just test with fetchRow or "take 1 $ fetchAllRows" -}
