module Data.List (chunk, splitAt) where

-- takes a list and divides it into n sized sub-lists
chunk : Int -> [b] -> [[b]]
chunk n xs = 
  let
    go bs =
      let
        (a,b) = splitAt n bs
      in
        if (a == []) then [] else (a :: go b)
  in
    go xs

-- splits a list into 2 segments at a given index
splitAt : Int -> [a] -> ([a],[a])
splitAt n xs = (take n xs, drop n xs)