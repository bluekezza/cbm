module Core ( error
            , divMod
            , lookup
            , atStart
            , onStart
            , sampleStart
            , startSignal) where

import Native.Error

-- raise an error message
error : a -> b
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

{- Elm Starting Signals
   https://groups.google.com/d/msg/elm-discuss/X4wmckEtMyg/_OY5YL1Heys -}

{- So atStart generates the following events
   Count=1   , 2    , 3
   Value=True, False, False (at 25fps) -}
atStart : Signal Bool
atStart = (\c -> c == 1 ) <~ (count <| fps 25)

{- onStart filters out only the first starting event -}
onStart : Signal Bool
onStart = keepIf id False atStart

{- Allows another signal (say Mouse.position) to be sampled on to the onStart signal. -}
sampleStart : Signal a -> Signal a
sampleStart s = sampleOn onStart s

{- Generates an Int on app Start -}
startSignal : Signal Int
startSignal = foldp (\v acc -> abs acc) (-1) (sampleStart (constant 0))