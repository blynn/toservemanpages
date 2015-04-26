-- A server that uses SSE (server-sent events) to stream the value of an
-- integer counter that starts at 0 and increases by 1 every second.
--
-- To see it in action, run this server then run:
--
--  $ curl localhost:3000

import Blaze.ByteString.Builder
import Data.ByteString.Char8 (pack)
import Control.Concurrent.MVar
import Control.Concurrent
import Control.Monad
import Network.Wai.EventSource
import Network.Wai.Handler.Warp (runEnv)

main :: IO ()
main = do
  ch <- newChan
  _ <- forkIO $ tick ch
  runEnv 3000 $ eventSourceAppChan ch

tick :: Chan ServerEvent -> IO ()
tick ch = do
  m <- newMVar (0 :: Integer)
  forever $ do
    n <- takeMVar m
    putMVar m (n + 1)
    writeChan ch $ ServerEvent Nothing Nothing [fromByteString (pack $ show n)]
    threadDelay 1000000
