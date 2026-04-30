module Logic where

import Types

  -- Calcula a porcentagem de leitura (protegendo contra divisão por zero)
calcProgress :: Book -> Float
calcProgress book
  | totalPages book == 0 = 0
  | otherwise = (fromIntegral (readPages book) / fromIntegral (totalPages book)) * 100

-- Filtra livros com avaliação igual ou superior ao parâmetro
filterByMinRating :: Int -> [Book] -> [Book]
filterByMinRating minStars = filter (\b -> rating b >= minStars)

-- Livros que ainda não foram iniciados
notStarted :: [Book] -> [Book]
notStarted = filter (\b -> readPages b == 0)

-- Livros concluídos (100%)
finished :: [Book] -> [Book]
finished = filter (\b -> readPages b >= totalPages b && totalPages b > 0)

-- Média de avaliação da lista
averageRating :: [Book] -> Float
averageRating [] = 0
averageRating books = fromIntegral (sum (map rating books)) / fromIntegral (length books)