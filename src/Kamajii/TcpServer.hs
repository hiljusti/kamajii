module Kamajii.TcpServer (serverMain) where

import Control.Monad (forM_)
import Control.Monad.IO.Class (MonadIO)
import Data.ByteString (ByteString)
import Data.ByteString.Char8 (pack, snoc, unpack)
import qualified Kamajii.Meta as Meta
import Network.Simple.TCP
  ( HostPreference (Host),
    SockAddr,
    Socket,
    recv,
    send,
    serve,
  )
import Kamajii.Stack (processStackCommand)

programName :: ByteString
programName = pack Meta.programName

serverMain :: String -> String -> IO ()
serverMain host port = do
  putStrLn $ "Serving on " ++ host ++ ":" ++ port
  serve (Host host) port handleClient

handleClient :: (Socket, SockAddr) -> IO ()
handleClient (socket, remoteAddr) = do
  putStrLn $ "[INFO] TCP connection established from " ++ show remoteAddr
  sendLn socket programName
  clientLoop socket
  putStrLn $ "[INFO] TCP connection terminated from " ++ show remoteAddr

clientLoop :: Socket -> IO ()
clientLoop socket = do
  maybe_bytes <- recv socket 2048
  with maybe_bytes $ \bytes -> do
    let line = unpack bytes
    putStrLn $ "[DEBUG] Received command: " ++ line
    let input = words line
    unless (input `elem` [["\EOT"], ["exit"], ["q"], ["quit"]]) $ do
      maybe_chars <- processStackCommand input
      with maybe_chars $ sendLn socket . pack
      clientLoop socket
  where
    with :: Maybe a -> (a -> IO ()) -> IO ()
    with Nothing _ = return ()
    with (Just a) io = io a

    unless :: Bool -> IO () -> IO ()
    unless True _ = return ()
    unless False io = io

sendLn :: MonadIO m => Socket -> ByteString -> m ()
sendLn socket bs = send socket $ snoc bs '\n'
