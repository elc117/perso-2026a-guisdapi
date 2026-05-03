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
    { bookId :: Int
    , title :: String
    , author :: String
    , publishYear :: Int
    , genre :: String
    , totalPages :: Int
    , readPages :: Int
    , rating :: Int
    , notes :: String
    , status :: Status
    } deriving (Show, Generic)

instance ToJSON Book
instance FromJSON Book

instance FromRow Book where
    -- Mapeia rigorosamente as 10 colunas vindas do SELECT no banco
    fromRow = Book <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> (read <$> field)

instance ToRow Book where
    -- Desestrutura os 10 atributos do Book e prepara para o banco de dados
    toRow (Book id_ t auth year gen tp rp rat ns st) = 
        toRow (id_, t, auth, year, gen, tp, rp, rat, ns, show st)

-- Representa o payload de resposta da nossa rota de estatísticas
data Stats = Stats
    { totalBooks :: Int
    , totalPagesRead :: Int
    , averageRating :: Float
    , readingCount :: Int
    , finishedCount :: Int
    } deriving (Show, Generic)

instance ToJSON Stats