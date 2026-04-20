import Test.HUnit
import Logic
import Types

testCalcProgress :: Test
testCalcProgress = TestCase (assertEqual "Progresso de 50%" 50.0 (calcProgress (Book 1 "Vidas Secas" 120 60 5 "Incrível")))

testFilterRating :: Test
testFilterRating = TestCase $ do
  let b1 = Book 1 "Livro A" 100 100 5 ""
  let b2 = Book 2 "Livro B" 100 50 3 ""
  assertEqual "Deve retornar apenas livros com nota >= 4" [b1] (filterByMinRating 4 [b1, b2])

tests :: Test
tests = TestList [TestLabel "testCalcProgress" testCalcProgress, TestLabel "testFilterRating" testFilterRating]

main :: IO Counts
main = runTestTT tests