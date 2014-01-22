module Core (error, divMod, lookup) where

import Native.Error

-- raise an error message
error msg = Native.Error.raise msg

-- provides a tuple of div and mod
divMod : Int -> Int -> (Int, Int)
divMod n d = (div n d, mod n d)

-- lookup a key from a key-value list
lookup : a -> [(a,b)] -> Maybe b
lookup key kvs =
  if | kvs == [] -> Nothing
     | otherwise -> let
                      (k,v) = head kvs
                    in
                      if (key == k) then (Just v) else (lookup key (tail kvs))
