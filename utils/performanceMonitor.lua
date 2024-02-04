
function logPerformance(time, fps)
  
  local filePath = system.pathForFile("performanceData/performanceLog.txt", system.ResourceDirectory)    
  -- Open the file handle
  local file, errorString = io.open( filePath, "a" )
      
  if not file then
      -- Error occurred; output the cause
      print( "File error: " .. errorString )
      return false
  else
      -- Write encoded JSON data to file
      file:write( time/1000, ": ",  fps, "fps\n" )
      -- Close the file handle
      io.close( file )
      return true
  end

end