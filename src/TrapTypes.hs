
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

type TrapLog = (ZonedTime, HostName, Trap)

data Trap = Trap { agentAddr :: T.Text
                 , version :: Integer
                 , community :: T.Text
                 , enterprise :: OID
                 , generic :: Integer
                 , specific :: Integer
                 , trapoid :: OID
                 , varbind :: [ASN1]
                 } deriving Show

instance Default Trap where
  def = Trap { agentAddr = undefined
             , version = undefined
             , community = undefined
             , enterprise = undefined
             , generic = undefined
             , specific = undefined
             , trapoid = undefined
             , varbind = undefined
             }

instance ASN1Object Trap where
  toASN1 _ = const undefined

  fromASN1 _ = Left "fromASN1: Parse error"

