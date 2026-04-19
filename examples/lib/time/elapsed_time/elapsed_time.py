import time

def elapsed_time(start_time, end_time=None):
  """
Format elapsed time as a human-readable string showing days, hours, minutes, seconds.

Args:
  start_time: Starting time from time.perf_counter()
  end_time: Ending time (defaults to current time)

Returns:
  String formatted as "[Nd] [NNh] [NNm] NN.NNNs"
  """

  # Use current time if end_time not provided
  if end_time is None:
    end_time = time.perf_counter()
  
  # Calculate total seconds
  elapsed = end_time - start_time
  
  # Initialize empty list for time components
  parts = []
  
  # Calculate days
  days = int(elapsed // 86400)
  if days:
    parts.append(f"{days}d")
    elapsed %= 86400
  
  # Calculate hours
  hours = int(elapsed // 3600)
  if hours or days:  # Show hours if we have days
    parts.append(f"{hours:02}h")
    elapsed %= 3600
  
  # Calculate minutes
  minutes = int(elapsed // 60)
  if minutes or hours or days:  # Show minutes if we have hours/days
    parts.append(f"{minutes:02}m")
    elapsed %= 60
  
  # Always show seconds
  parts.append(f"{elapsed:06.3f}s")
  
  return " ".join(parts)

#fin
