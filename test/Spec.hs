import Test.HUnit
import Logic
import Types

testCalcProgress :: Test
testCalcProgress = TestCase (assertEqual "Progresso de 50%" 50.0 (calcProgress (Book 1 "Vidas Secas" 120 60 5 "Incrível" Finished)))

testFilterRating :: Test
testFilterRating = TestCase $ do
  let b1 = Book 1 "Livro A" 100 100 5 "" Finished
  let b2 = Book 2 "Livro B" 100 50 3 "" Reading
  assertEqual "Deve retornar apenas livros com nota >= 4" [b1] (filterByMinRating 4 [b1, b2])

testCalcProgressZeroPages :: Test
testCalcProgressZeroPages = TestCase $
  assertEqual "Progresso com 0 páginas" 0.0 (calcProgress (Book 1 "Vazio" 0 0 3 "" WantToRead))

testFilterEmptyList :: Test
testFilterEmptyList = TestCase $
  assertEqual "Filtro em lista vazia" [] (filterByMinRating 4 [])

testFilterNoMatch :: Test
testFilterNoMatch = TestCase $
  assertEqual "Nenhum livro aprovado" [] (filterByMinRating 5 [Book 1 "X" 100 50 3 "" Reading])

tests :: Test
tests = TestList 
  [ TestLabel "testCalcProgress" testCalcProgress
  , TestLabel "testFilterRating" testFilterRating
  , TestLabel "testCalcProgressZeroPages" testCalcProgressZeroPages
  , TestLabel "testFilterEmptyList" testFilterEmptyList
  , TestLabel "testFilterNoMatch" testFilterNoMatch
  ]

main :: IO Counts
main = runTestTT tests