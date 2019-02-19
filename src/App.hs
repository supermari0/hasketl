module App ( HaskETLConfig (..)
           , HaskETL (..)
           , module Control.Monad.Trans.Reader
           , module Control.Monad.IO.Class
           , runHaskETL'
           , runHaskETL
           ) where

import Control.Monad.Trans.Reader
import Control.Monad.IO.Class

data HaskETLConfig = HaskETLConfig

newtype HaskETL m a = HaskETL { unHaskETL :: ReaderT HaskETLConfig m a }
  deriving (Functor, Applicative, Monad, MonadIO)

runHaskETL' :: MonadIO m => m HaskETLConfig -> HaskETL m a -> m a
runHaskETL' cfg = (cfg >>=) . runReaderT . unHaskETL

runHaskETL :: HaskETL IO a -> IO a
runHaskETL = runHaskETL' cmdlineConfig

cmdlineConfig :: IO HaskETLConfig
cmdlineConfig = pure HaskETLConfig
