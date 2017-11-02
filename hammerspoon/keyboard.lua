-- Switch between Karabiner-Elements profiles by keyboard

function switchKarabinerElementsProfile(name)
    hs.execute(utils.shelljoin(
        "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli",
        "--select-profile",
        name
    ))
  end
  
  usb.onChange(function (device)
      local name = device.productName
      if name and (
          name:find("PS2") or  -- I still use PS/2 Kinesis Keyboard via USB adapter...
            (not device.vendorName:find("^Apple") and name:find("Keyboard"))
        ) then
        if device.eventType == "added" then
          switchKarabinerElementsProfile("VNG")
        else
          switchKarabinerElementsProfile("MacPro")
        end
      end
  end)