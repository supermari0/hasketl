module Lib
    ( someFunc
    ) where

import App
import qualified Database.HDBC as HDBC


someFunc :: IO ()
someFunc = runHaskETL $
  liftIO $ putStrLn "someFunc"

data Row = Row [ HDBC.SqlValue ]

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
