
module Receiver
( trapReceiver
) where

import Config
import TrapTypes

import Control.Exception
import Control.Monad.IO.Class
import Data.ASN1.BinaryEncoding
import Data.ASN1.Encoding
import Data.ASN1.Types
import Data.Conduit
import Data.Conduit.Network.UDP
import Data.Time.LocalTime
import Network.Socket
import System.IO


trapReceiver :: SockAddr -> IO ()
trapReceiver sockAddr =
  withFile "./log/snmptrap.log" AppendMode $ \hdl -> do
    hSetBuffering hdl NoBuffering
    withSocketsDo $ bracket (socket AF_INET Datagram 0) close $ \sock -> do
      bind sock sockAddr
      loop hdl sock
  where loop h s = (sourceSocket s maxUdpFrameBytes
                   $= parsingMsg
                   $$ loggingMsgTo h
                   ) >> loop h s


parsingMsg :: Conduit Message IO TrapLog
parsingMsg = do
  mbMsg <- await
  case mbMsg of
    Nothing -> return ()
    Just (Message msg sender) -> do
      time <- liftIO getZonedTime
      asn1 <- liftIO $ either throwIO return $ decodeASN1' BER msg
      trap <- liftIO $ either (throwIO . ErrorCall) return $ fst <$> fromASN1 asn1
      (Just hostname,_) <- liftIO $ getNameInfo [] True False sender
      yield (time, hostname, trapoid trap, varbind trap) >> parsingMsg


loggingMsgTo :: Handle -> Sink TrapLog IO ()
loggingMsgTo h = do
  mbTrapLog <- await
  case mbTrapLog of
    Nothing -> return ()
    Just traplog -> liftIO $ hPrint h traplog

