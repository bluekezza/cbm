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

-- Model
allSad : [(Int, Bool)]
allSad = map (\i -> (i, False)) [0..15]

-- Update
change n moods = 
  let
    switcher (i, m) = if (i == n) then (i, not m) else (i, m)
  in
    map (switcher) moods

-- Display
size = 150
img = fittedImage size size

face : (Int, Bool) -> Element
face (i, happy) = 
  let
    name = if happy then "happy" else "sad"
  in
    img ("/img/" ++ (show i) ++ "_" ++ name ++ ".png")

faces : [(Int, Bool)] -> [Element]
faces moods = map (face) moods

grid : Int -> [Element] -> Element
grid n elems =
  let
    ess = chunk n elems
    acrosses = map (\es -> flow right es) ess
    downs = flow down acrosses
  in
    downs

main = grid 4 (faces (change 3 allSad))

