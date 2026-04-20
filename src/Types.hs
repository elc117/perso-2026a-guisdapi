module Types where

data Book = Book 
  { bookId     :: Int
  , title      :: String
  , totalPages :: Float  -- Usando Float para facilitar a divisão da porcentagem
  , readPages  :: Float
  , rating     :: Int    -- Ex: 1 a 5 estrelas
  , notes      :: String
  } deriving (Show, Eq)
