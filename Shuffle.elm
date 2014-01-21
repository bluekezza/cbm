module Shuffle (shuffle) where

-- #http://rosettacode.org/wiki/Knuth_shuffle#Haskell
-- #http://www.leetorlame.com/top/18/

import open Data.List
import open Generator
import open Generator.Standard

shuffleInner : [a] -> [a] -> Generator Standard -> ([a], Generator Standard)
shuffleInner bs acc gen =
  case (bs) of
    [] -> (acc, gen)
    otherwise -> let
                   (k, gen') = int32Range (0, length bs - 1) gen
                   (lead, x :: xs) = splitAt k bs
                   bs' = (lead ++ xs)
                   acc' = (x :: acc)
                 in
                   shuffleInner bs' acc' gen'
{-
                   let
                   (k, gen') = int32Range (0, length bs - 1) gen
                   (lead, ys) = splitAt k bs
                   (x, xs) = splitAt 1 ys
                   bs' = (lead ++ xs)
                   acc' = (x :: acc)
                 in
                   shuffleInner bs' acc' gen'
-}
                   

shuffle : [a] -> Generator Standard -> ([a], Generator Standard)
shuffle xs gen = shuffleInner xs [] gen

{-
import System.Random

shuffle : [a] -> IO [a]
shuffle l = shuffleInner l []
  where
    shuffleInner [] acc = return acc
    shuffleInner l acc =
      do k <- randomRIO (0, length l - 1)
         let (lead, x:xs) = splitAt k l
         shuffleInner (lead ++ xs) (x:acc)
-}