import Test.HUnit
import Logic
import Types

-- Livro base para testes
livroTeste :: Book
livroTeste = Book 1 "Vidas Secas" "Graciliano Ramos" 1938 "Romance" 120 60 5 "Incrível" Finished

testCalcProgress :: Test
testCalcProgress = TestCase (assertEqual "Progresso de 50%" 50.0 (calcProgress livroTeste))

testValidateBookSuccess :: Test
testValidateBookSuccess = TestCase $ 
    case validateBook livroTeste of
        Right _ -> return () -- Se retornou Right, o teste passou
        Left _  -> assertFailure "Livro válido foi rejeitado pela lógica."

testValidateBookFutureYear :: Test
testValidateBookFutureYear = TestCase $ 
    let livroFuturo = livroTeste { publishYear = 2050 }
    in case validateBook livroFuturo of
        Left err -> assertEqual "Erro correto" "O ano de publicacao nao pode ser no futuro." err
        Right _  -> assertFailure "Livro do futuro não foi bloqueado."

testValidateBookPagesError :: Test
testValidateBookPagesError = TestCase $ 
    let livroErro = livroTeste { readPages = 150, totalPages = 120 } -- Leu mais do que o total
    in case validateBook livroErro of
        Left err -> assertEqual "Erro correto" "Inconsistencia: paginas lidas excedem o total." err
        Right _  -> assertFailure "Inconsistência de páginas não bloqueada."

tests :: Test
tests = TestList 
    [ TestLabel "testCalcProgress" testCalcProgress
    , TestLabel "testValidateBookSuccess" testValidateBookSuccess
    , TestLabel "testValidateBookFutureYear" testValidateBookFutureYear
    , TestLabel "testValidateBookPagesError" testValidateBookPagesError
    ]

main :: IO Counts
main = runTestTT tests