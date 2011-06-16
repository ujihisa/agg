import qualified System as S
import System.IO (openTempFile, hClose)
import System.Directory (getTemporaryDirectory)
import Text.Regex.Posix ((=~))
import Control.Monad (forM_)
import Text.Regex.Gsub (gsub)

main = do
  args <- S.getArgs
  if length args == 1
     then do
       file <- readFile $ head args
       let chunks = chunkize (lines file)
       forM_ chunks $ \chunk -> do
         tempdir <- getTemporaryDirectory
         (tmpfile, handle) <- openTempFile tempdir "a"
         hClose handle
         writeFile tmpfile (unlines $ tail chunk)
         let cmd = gsub (head chunk) "^-- \\$ " ""
         putStrLn $ "$ " ++ cmd
         S.system $ gsub cmd "this" tmpfile
     else
       putStrLn "USAGE: agg aggfilename"

chunkize :: [String] -> [[String]]
chunkize ss = reverse $ map reverse $ foldl f [] ss
  where
    f :: [[String]] -> String -> [[String]]
    f xs s = if s =~ "^-- \\$ "
                then ([s] : xs)
                else ((s : head xs) : tail xs)
