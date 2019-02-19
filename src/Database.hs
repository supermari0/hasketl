module Database
    (DatabaseTable
    ,SpecificRow
    ,DatacenterRow
    ,DatacenterTable
    ,hdbcToGenericRow
    ) where

import qualified Data.Convertible.Base as Convertible
import qualified Database.HDBC as HDBC

-- TODO This is a stub for now, it will have whatever we need to serialize to
-- Avro eventually
class DatabaseTable a

-- A specific row having particular columns with particular types
class SpecificRow a where
  -- TODO make this generic Either String a
  fromGenericRow :: GenericRow -> Convertible.ConvertResult a

-- example row in datacenter table: datacenter ID, datacenter abbreviation,
-- ticket queue ID
data DatacenterRow = DatacenterRow Int String Int deriving Show
instance SpecificRow DatacenterRow where
  -- TODO This will basically be the same for any SpecificRow. We should figure
  -- out how to do a default implementation, ideally so anything deriving the
  -- typeclass can use it.
  fromGenericRow (GenericRow[dcID, abbr, qID]) = DatacenterRow
    <$> HDBC.safeFromSql dcID
    <*> HDBC.safeFromSql abbr
    <*> HDBC.safeFromSql qID
  fromGenericRow r = Convertible.convError "Could not parse a datacenter row" r

newtype DatacenterTable = DatacenterTable [ DatacenterRow ] deriving Show
instance DatabaseTable DatacenterTable

-- A generic row having any number of columns
newtype GenericRow = GenericRow [ HDBC.SqlValue ] deriving Show

hdbcToGenericRow :: Maybe [HDBC.SqlValue] -> Maybe GenericRow
hdbcToGenericRow = fmap GenericRow
