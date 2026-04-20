{-# LANGUAGE OverloadedStrings #-}

-- Execute com:
--   runhaskell helloNameScotty.hs
--
-- Ou compile e execute com:
--   ghc -threaded -o mywebapp helloNameScotty.hs
--   ./mywebapp
--
-- Teste local:
--   curl http://localhost:3000/hello/Andrea
--
-- Teste no Codespaces:
--   acesse /hello/<nome> na URL pública encaminhada para a porta 3000

import Web.Scotty
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import qualified Data.Text.Lazy as T

-- Função pura: recebe um nome e produz a mensagem
makeGreeting :: String -> String
makeGreeting name = "Hello, " ++ name ++ "!"

main :: IO ()
main = scotty 3000 $ do
  middleware logStdoutDev

  get "/hello/:name" $ do
    name <- pathParam "name"
    text (T.pack (makeGreeting name))