{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Types where

import GHC.Generics (Generic)
import Data.Aeson (ToJSON, FromJSON)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField
import Database.SQLite.Simple.ToField
import Database.SQLite.Simple.Ok

data Status = WantToRead | Reading | Finished
  deriving (Show, Eq, Generic, Read)

instance ToJSON Status
instance FromJSON Status

-- Ensina o SQLite a gravar o Status como texto
instance ToField Status where
    toField = toField . show

-- Ensina o SQLite a ler o texto e transformar de volta em Status
instance FromField Status where
    fromField f = do
        t <- fromField f
        case reads t of
            [(val, "")] -> Ok val
            _           -> returnError ConversionFailed f "Invalid Status"

data Book = Book 
  { bookId     :: Int
  , title      :: String
  , totalPages :: Int
  , readPages  :: Int
  , rating     :: Int
  , notes      :: String
  , status     :: Status
  } deriving (Show, Eq, Generic)

instance ToJSON Book
instance FromJSON Book

-- Mapeia as colunas da tabela (SELECT) para o objeto Book
instance FromRow Book where
  fromRow = Book <$> field <*> field <*> field <*> field <*> field <*> field <*> field

-- Mapeia o objeto Book para os valores da tabela (INSERT)
instance ToRow Book where
  toRow (Book id_ t tp rp rat ns st) = toRow (id_, t, tp, rp, rat, ns, st)