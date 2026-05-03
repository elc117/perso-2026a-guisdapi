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

-- Validação de dados com o tipo algébrico Either
-- Se falhar, retorna 'Left' com o erro. Se passar, retorna 'Right' com o livro.
validateBook :: Book -> Either String Book
validateBook book
    | totalPages book <= 0 = Left "O livro deve ter pelo menos 1 pagina."
    | readPages book < 0 = Left "O numero de paginas lidas nao pode ser negativo."
    | readPages book > totalPages book = Left "Inconsistencia: paginas lidas excedem o total."
    | rating book < 0 || rating book > 5 = Left "A nota de avaliacao deve estar entre 0 e 5."
    | publishYear book > 2026 = Left "O ano de publicacao nao pode ser no futuro."
    | otherwise = Right book

-- Função que demonstra a aplicação de `foldl` sobre uma lista para compor um novo resultado.
-- Se a lista for vazia, devolve tudo zerado para evitar divisão por zero
calculateStats :: [Book] -> Stats
calculateStats [] = Stats 0 0 0.0 0 0
calculateStats books = 
    let tBooks = length books
        tPagesRead = foldl (\acc b -> acc + readPages b) 0 books
        
        -- Isolamos estritamente os livros com avaliação válida
        ratedBooks = filter (\b -> rating b > 0) books
        ratedCount = length ratedBooks
        totalRating = foldl (\acc b -> acc + rating b) 0 ratedBooks
        
        -- Cálculo da média protegido contra divisão por zero
        avgRating = if ratedCount > 0 
                    then fromIntegral totalRating / fromIntegral ratedCount 
                    else 0.0
        
        reading = length (filter (\b -> status b == Reading) books)
        finished = length (filter (\b -> status b == Finished) books)
        
    in Stats tBooks tPagesRead avgRating reading finished