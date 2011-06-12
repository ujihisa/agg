import qualified System as S
import System.IO (openTempFile, hClose)
import System.Directory (getTemporaryDirectory)
import Text.Regex.Posix ((=~))
import Control.Monad (forM_)
import Data.String.Utils (replace)

main = do
  args <- S.getArgs
  if length args == 1
     then do
       file <- readFile $ head args
       let chunks = chunkize (lines file)
       forM_ (commandize chunks) $ \(cmd, file) -> do
         tempdir <- getTemporaryDirectory
         (tmpfile, handle) <- openTempFile tempdir "a"
         hClose handle
         writeFile tmpfile file
         putStrLn $ "$ " ++ cmd
         S.system $ replace "this" tmpfile cmd
     else
       putStrLn "USAGE: agg aggfilename"

chunkize :: [String] -> [[String]]
chunkize ss = reverse $ map reverse $ foldl f [] ss
  where
    f :: [[String]] -> String -> [[String]]
    f xs s = if s =~ "^-- \\$ "
                then ([s] : xs)
                else ((s : head xs) : tail xs)

commandize :: [[String]] -> [(String, String)]
commandize xs = map f xs
  where
    f :: [String] -> (String, String)
    f (x:xs) = (drop 5 x, unlines xs)

