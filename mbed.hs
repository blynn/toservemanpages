{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
import Blaze.ByteString.Builder
import Data.ByteString.Char8 (pack)
import Data.FileEmbed
import Data.List (isSuffixOf)
import Data.Map (fromList, (!), member)
import Network.Wai
import Network.Wai.Handler.Warp (runEnv)
import Network.HTTP.Types
import Network.HTTP.Types.Header

m = let
  m0 = map (\(k, v) -> (('/':k), v)) $(embedDir "www")
  m1 = [(take (length k - 10) k , v)
    | (k, v) <- m0, "/index.html" `isSuffixOf` k]
  in fromList $ map (\(k, v) -> (pack k, v)) (m0 ++ m1)

main = runEnv 3000 $ \req f -> case requestMethod req of
  "GET" -> do
    putStrLn $ show (remoteHost req) ++ " " ++ show (rawPathInfo req)
    let k = rawPathInfo req
    f $ if k `member` m then responseBuilder status200 [] $ fromByteString (m!k)
                        else responseBuilder status301 [(hLocation, "/")]
                             $ fromByteString "Redirecting to /"
