-- Webserver serving from current directory.

{-# LANGUAGE OverloadedStrings #-}
import Data.Binary.Builder
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as BL
import Data.List (isSuffixOf)
import Control.Exception (try, displayException, SomeException)
import Network.Wai
import Network.Wai.Handler.Warp (runEnv)
import Network.HTTP.Types

toFilename :: String -> String
toFilename s = dropWhile ('/' ==) $ if '/' == last s then s ++ "index.html" else s

main :: IO ()
main = runEnv 3000 $ \req f -> case requestMethod req of
  "GET" -> do
    putStrLn $ show (remoteHost req) ++ " " ++ show (rawPathInfo req)
    let filename = toFilename $ map (toEnum . fromEnum) $ BS.unpack $ rawPathInfo req
    r <- try $ BL.readFile filename
    f $ case r of
      Left ex -> responseBuilder status404 [] $ putStringUtf8 $ displayException (ex :: SomeException)
      Right s -> responseBuilder status200 (conTyp filename $ []) $ fromLazyByteString s
  _ -> f $ responseBuilder status200 [] "OK"
  where
  conTyp filename
    | isSuffixOf ".wasm.gz" filename = ((hContentEncoding, "gzip"):) . ((hContentType, "application/wasm"):)
    | isSuffixOf ".wasm" filename = ((hContentType, "application/wasm"):)
    | isSuffixOf ".mjs" filename = ((hContentType, "application/javascript"):)
    | otherwise = id
