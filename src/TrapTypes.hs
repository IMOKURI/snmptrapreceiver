
module TrapTypes
( TrapLog
, Trap(..)
) where

import Data.ASN1.Types
import Data.Default
import qualified Data.Text as T
import Data.Text.Encoding
import Data.Time.LocalTime
import Network.Socket

type TrapLog = (ZonedTime, HostName, OID, [ASN1])

data Trap = Trap { agentAddr :: T.Text
                 , community :: T.Text
                 , trapoid :: OID
                 , varbind :: [ASN1]
                 } deriving Show

instance Default Trap where
  def = Trap { agentAddr = undefined
             , community = undefined
             , trapoid = undefined
             , varbind = undefined
             }

instance ASN1Object Trap where
  toASN1 _ = const undefined

  -- SNMP version 1
  fromASN1 ( Start Sequence                   -- SNMP packet start
           : IntVal 0                           -- SNMP version: version-1
           : OctetString comm              -- SNMP community
           : Start (Container Context 4)        -- SNMP trap pdu v1 start
           : OID ent                     -- Enterprise OID
           : Other Application 0 addr     -- Agent Address
           : IntVal gen                   -- Generic trap
           : IntVal spec                  -- Specific trap
           : Other Application 3 _        -- Time ticks
           : vars ) = Right ( def { agentAddr  = decodeUtf8 addr
                                  , community  = decodeUtf8 comm
                                  , trapoid    = if gen == 6 then ent ++ [0,spec] else [1,3,6,1,6,3,1,1,5,gen+1]
                                  , varbind    = filter (`notElem` construction) vars }
                            , [] )

  -- SNMP version 2
  fromASN1 ( Start Sequence                   -- SNMP packet start
           : IntVal 1                           -- SNMP version: version-2c
           : OctetString comm              -- SNMP community
           : Start (Container Context 7)        -- SNMP trap pdu v2c start
           : IntVal _                     -- Request-id
           : IntVal 0                             -- Error Status: noError
           : IntVal _                             -- Error Index
           : Start Sequence                       -- Variable binding list start
           : Start Sequence                         -- 1st variable binding start
           : OID [1,3,6,1,2,1,1,3,0]                  -- Object name: sysUpTimeInstance
           : Other Application 3 _            -- Time ticks
           : End Sequence                           -- 1st variable binding end
           : Start Sequence                         -- 2nd variable binding start
           : OID [1,3,6,1,6,3,1,1,4,1,0]              -- Object name: snmpTrapOID
           : OID trapid                          -- SNMP Trap OID
           : End Sequence                           -- 2nd variable binding end
           : vars ) = Right ( def { community  = decodeUtf8 comm
                                  , trapoid    = trapid
                                  , varbind    = filter (`notElem` construction) vars }
                            , [] )

  fromASN1 _ = Left "fromASN1: Parse error"

construction :: [ASN1]
construction = [Start Sequence, End Sequence, End (Container Context 4), End (Container Context 7)]

