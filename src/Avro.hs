module Avro
    () where

import Data.Avro
import Data.Avro.Schema as S
import qualified Data.Avro.Types  as AT
import qualified Database as DB

-- TODO Next steps for this module:
-- 1. Make the below more readable; use the actual constructors and/or helpers
-- 2. Import qualified all the above so it's more obvious what we're doing
-- 3. Finish the rest of the implementation, making this an instance of
-- HasAvroSchema
-- 4. Create a fake database table record in a test, serialize to /tmp and
-- deserialize, ensure both are equivalent
databaseSchema :: Schema
databaseSchema =
  Record "Database" [] Nothing Nothing
  [ fld "id" Int Nothing
  , fld "abbreviation" String Nothing
  , fld "queueID" Int Nothing]
  where fld nm ty def = Field nm [] Nothing Nothing ty def
