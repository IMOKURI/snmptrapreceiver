
module Config
( maxUdpFrameBytes
, CLOptions(..)
, clOptions
, takeSockAddr
) where

import Control.Applicative
import Data.Monoid
import Network.Socket
import Options.Applicative

maxUdpFrameBytes :: Int
maxUdpFrameBytes = 8192


data CLOptions = CLOptions { takeServerHost :: HostName
                           , takeServerPort :: ServiceName }

clOptions :: ParserInfo CLOptions
clOptions = info ( helper <*> clOptions' )
              ( fullDesc
              <> header "snmptrapreceiver - Tool that receive snmp traps" )

clOptions' :: Parser CLOptions
clOptions' = CLOptions
  <$> strOption ( short 'i' <> metavar "IP"   <> help "IP address that is listened" <> value "0.0.0.0" )
  <*> strOption ( short 'p' <> metavar "PORT" <> help "PORT that is listened"       <> value "162" )


takeSockAddr :: CLOptions -> IO SockAddr
takeSockAddr opts = addrAddress <$> head <$> filter (\a -> addrFamily a == AF_INET)
                    <$> getAddrInfo Nothing (Just (takeServerHost opts)) (Just (takeServerPort opts))


