#!C:/opt/sensu/embedded/bin/ruby.exe
require 'sensu-plugin/metric/cli'
require 'socket'

class CurrentFileCacheMemoryUsageMetric < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to .$parent.$child',
         long: '--scheme SCHEME',
         default: Socket.gethostname.to_s

  def acquire_Current_File_Cache_Memory_Usage
    temp_arr = []
    timestamp = Time.now.utc.to_i
    IO.popen('typeperf -sc 1 "\Web Service Cache\Current File Cache Memory Usage" ') { |io| io.each { |line| temp_arr.push(line) } }
    temp = temp_arr[2].split(',')[1]
    metric = temp[1, temp.length - 3].to_f
    [metric, timestamp]
  end

  def run
    values = acquire_Current_File_Cache_Memory_Usage
    metrics = {
      Cache: {
        FileCacheMemoryUsage: values[0]
      }
    }
    metrics.each do |parent, children|
      children.each do |child, value|
        output [config[:scheme], parent, child].join('.'), value, values[1]
      end
    end
    ok
  end
end
