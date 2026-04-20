module Logic where

import Types

  -- Calcula a porcentagem de leitura (protegendo contra divisão por zero)
calcProgress :: Book -> Float
calcProgress book
  | totalPages book == 0 = 0
  | otherwise = (readPages book / totalPages book) * 100

-- Filtra livros com avaliação igual ou superior ao parâmetro
filterByMinRating :: Int -> [Book] -> [Book]
filterByMinRating minStars books = filter (\b -> rating b >= minStars) books