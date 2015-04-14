
module TrapTypes
( TrapLog
, Trap(..)
) where

import Data.ASN1.Types
import qualified Data.Text as T
import Data.Text.Encoding
import Data.Time.LocalTime
import Network.Socket

type TrapLog = (ZonedTime, HostName, Trap)

data Trap = Trap { agentAddr :: HostName
                 , version :: Integer
                 , community :: T.Text
                 } deriving Show

instance ASN1Object Trap where
  toASN1 t = const $ Start Sequence
                   : IntVal ((version t)-1)
                   : OctetString (encodeUtf8 (community t))
                   -- trap pdu
                   : End Sequence
                   : []
  fromASN1 ( Start Sequence
           : IntVal v
           : OctetString c
           -- trap pdu
           : xs ) = Right ( Trap { agentAddr = ""
                                 , version = (v+1)
                                 , community = decodeUtf8 c }, xs )
  fromASN1 _ = Left "fromASN1: Parse error"

