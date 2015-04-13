
module Main where

import Config
import Receiver

import Options.Applicative


main :: IO ()
main = do
  opts <- execParser clOptions
  sockAddr <- takeSockAddr opts
  trapReceiver sockAddr


