import db_sqlite, strformat, strutils, typetraits

proc formatLine(lineData: tuple) =
      echo "|", fmt"{lineData[0]:>2}", "|", fmt"{lineData[1]:>20}", "|", fmt"{lineData[2]:>5}", "|"

proc getTypesPrompt() =
        echo "Type in the ID and press Enter to open up items of that type or exit."
        formatLine(("ID", "Name", ""))
        formatLine((0, "Exit/Confirm Order", ""))
        formatLine((1, "Food", ""))
        formatLine((2, "Drinks", ""))

proc selectMenuItems(typeID: int): int =
  var itemID = readLine(stdin)
  let menu = open("menu.db", "","","")
  var input = 0
  for item in menu.fastRows(sql"""SELECT ItemName, ItemPrice FROM Items WHERE ItemID = ? AND TypeID = ?""", itemID, typeID):
    echo "Select ", item[0], "?"
    echo ("y/n")
    if readLine(stdin) == "y":
      input = parseInt(itemID)
  menu.close()
  return input

proc confirmOrder(itemIDs: seq) =
    let menu = open("menu.db", "","","")
    var total = 0.0
    for itemID in itemIDs:
        for item in menu.fastRows(sql"""SELECT ItemName, ItemPrice FROM Items WHERE ItemID = ? """, itemID):
          formatLine((itemID, item[0], item[1]))
          total = total + parseFloat(item[1])
    formatLine(("", "Total", total))
    menu.close()

proc getMenuItems(itemType: string) =
  let menu = open("menu.db", "","","")
  if itemType == "food":
    formatLine(("ID", "Name", "Price"))
    for x in menu.fastRows(sql"SELECT ItemID, ItemName, ItemPrice FROM Items WHERE TypeID = 1"):
      formatLine((x[0], x[1],x[2]))
  elif itemType == "drink":
    formatLine(("ID", "Name", "Price"))
    for x in menu.fastRows(sql"SELECT ItemID, ItemName, ItemPrice FROM Items WHERE TypeID = 2"):
      formatLine((x[0], x[1],x[2]))
  else:
    echo "Error pulling data (Incorrect Type Requested)"
  echo ""
  menu.close()

var order: seq[int] = @[]
getTypesPrompt()
while true:
    var input = readLine(stdin)
    if input == "1":
        getMenuItems("food")
        order.add(selectMenuItems(parseInt(input)))
        getTypesPrompt()
    elif input == "2":
        getMenuItems("drink")
        order.add(selectMenuItems(parseInt(input)))
        getTypesPrompt()
    elif input == "0":
        confirmOrder(order)
        break
    else:
        echo input, " is an invalid input."
        getTypesPrompt()

