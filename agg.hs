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
       forM_ chunks $ \(header:body) -> do
         tempdir <- getTemporaryDirectory
         (tmpfile, handle) <- openTempFile tempdir "a"
         hClose handle
         writeFile tmpfile (unlines body)
         let cmd = gsub header "^-- \\$ " ""
         putStrLn $ "$ " ++ cmd
         S.system $ gsub cmd "this" tmpfile
     else
       putStrLn "USAGE: agg aggfilename"

chunkize :: [String] -> [[String]]
chunkize ss = reverse $ map reverse $ foldl f [] ss
  where
    f :: [[String]] -> String -> [[String]]
    f xs s
      | s =~ "^-- \\$ " = [s] : xs
      | otherwise       = ((s : head xs) : tail xs)
