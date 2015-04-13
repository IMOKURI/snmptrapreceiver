
module Receiver
( trapReceiver
) where

import Config

import Control.Monad.IO.Class
import Data.Conduit
import Data.Conduit.Network.UDP
import Network.Socket


trapReceiver :: SockAddr -> IO ()
trapReceiver sockAddr = withSocketsDo $ do
  sock <- socket AF_INET Datagram 0
  bind sock sockAddr
  loop sock
    where loop s = (sourceSocket s maxUdpFrameBytes $$ loggingMsg) >> loop s

loggingMsg :: Sink Message IO ()
loggingMsg = do
  mbMsg <- await
  case mbMsg of
    Nothing -> return ()
    Just (Message msg sender) -> liftIO $ print sender


