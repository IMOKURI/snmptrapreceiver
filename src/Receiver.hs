
module Receiver
( trapReceiver
) where

import Config

import Control.Exception
import Control.Monad.IO.Class
import qualified Data.ByteString as B
import Data.Conduit
import Data.Conduit.Network.UDP
import Network.Socket
import System.IO


trapReceiver :: SockAddr -> IO ()
trapReceiver sockAddr =
  bracket (openFile "./log/snmptrap.log" AppendMode) hClose $ \handle -> do
    withSocketsDo $ bracket (socket AF_INET Datagram 0) close $ \sock -> do
      bind sock sockAddr
      loop handle sock
  where loop h s = (sourceSocket s maxUdpFrameBytes $$ (loggingMsg h)) >> loop h s

loggingMsg :: Handle -> Sink Message IO ()
loggingMsg h = do
  mbMsg <- await
  case mbMsg of
    Nothing -> return ()
    Just (Message msg sender) -> liftIO $ B.hPut h msg

