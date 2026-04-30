{-# LANGUAGE DeriveGeneric #-}
module Types where

import GHC.Generics (Generic)
import Data.Aeson (ToJSON, FromJSON)

data Status = WantToRead | Reading | Finished
  deriving (Show, Eq, Generic)

-- Derivação automática para conversão JSON
instance ToJSON Status
instance FromJSON Status

data Book = Book 
  { bookId     :: Int
  , title      :: String
  , totalPages :: Int
  , readPages  :: Int
  , rating     :: Int
  , notes      :: String
  , status     :: Status
  } deriving (Show, Eq, Generic)

-- Derivação automática para conversão JSON
instance ToJSON Book
instance FromJSON Book