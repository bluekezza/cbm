import Input as I
import Error

-- Prelude
divMod : Int -> Int -> (Int, Int)
divMod n d = (div n d, mod n d)

-- Data.list
splitAt : Int -> [a] -> ([a],[a])
splitAt n xs = (take n xs, drop n xs)

chunk : Int -> [b] -> [[b]]
chunk k xs = 
  let
    go bs =
      let
        (a,b) = splitAt k bs
      in
        if (a == []) then [] else (a :: go b)
  in
    go xs

lookup : a -> [(a,b)] -> Maybe b
lookup key xys =
  if | xys == [] -> Nothing
     | otherwise -> let
                      (x,y) = head xys
                    in
                      if (key == x) then (Just y) else (lookup key (tail xys))

-- Model
state = change 0 allSad

allSad : [(Int, Bool)]
allSad = map (\i -> (i, False)) [0..15]

-- Update
change n moods =
  let
    switcher (i, m) = if (i == n) then (i, not m) else (i, m)
  in
    map (switcher) moods

select n model =
  let
    nextSeed = (n + 1) `mod` 16
    match = lookup n model
  in
    case match of
      (Just True) -> change nextSeed (change n model)
      (Just False) -> model
      Nothing -> model

step : Maybe Int -> [(Int, Bool)] -> [(Int, Bool)]
step m model = 
  case (m) of Nothing -> Error.raise "No n supplied"
              (Just n) -> select n model

-- Display
size : Int
size = 150

img : String -> Element
img = fittedImage size size

face : (Int, Bool) -> Element
face (i, happy) = 
  let
    name = if happy then "happy" else "sad"
    e = img ("/img/" ++ (show i) ++ "_" ++ name ++ ".png")
  in
    faceButton.button (Just i) e

faces : [(Int, Bool)] -> [Element]
faces moods = map (face) moods

grid : Int -> [Element] -> Element
grid n elems =
  let
    ess = chunk n elems
    acrosses = map (\es -> flow right es) ess   --flow allows you to go from [Element] -> Element
    downs = flow down acrosses
  in
    downs

render : [(Int, Bool)] -> Element
render state = 
  let 
    g = grid 4 (faces state)
  in
    if (not debug) then g else flow down [ g, asText state ]

faceButton : { events : Signal (Maybe Int)
             , button : Maybe Int -> Element -> Element }
faceButton = I.buttons Nothing

input : Signal (Maybe Int)
input = faceButton.events

main : Signal Element
main = lift render (foldp step state input)

debug : Bool
debug = False