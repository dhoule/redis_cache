class RedisCache
  
  def initialize( hash, foreign=false, parent=nil, resource=nil, start=0, count=0, from=nil, to=nil, plural=nil, singular=nil )
    @hash = hash
    @foreign = foreign
    @parent = parent
    @resource = resource
    @start = start
    @count = count
    @from = from
    @to = to
    @plural = plural
    @singular = singular

    value = get_value
    $redis.set @hash, value
    self.delay(:run_at => REDIS_CACHE_REFRESH.to_i.seconds.from_now).refresh()
    $redis.expire @hash, REDIS_CACHE_TIMEOUT.to_i 
  end  

  def refresh
    value = get_value
    if $redis.keys.include?( @hash )
      ttl = $redis.ttl @hash
      $redis.set( @hash, Marshal.dump( value.to_json ) )       
      ( ttl > 0 ? $redis.expire( @hash, ttl ) : $redis.expire( @hash, REDIS_CACHE_TIMEOUT.to_i ) )
      self.delay(:run_at => REDIS_CACHE_REFRESH.to_i.seconds.from_now).refresh()
    end  
  end  

  private

    def get_value
      if !@from.nil?
        temp = ( @foreign ? foreign_date_index() : local_date_index() )
      elsif !@start.nil?
        temp = ( @foreign ? foreign_limit_index() : local_limit_index() )
      else
        temp = ( @foreign ? @parent.send(@plural) : @resource.all() )
      end
      temp
    end  

    def foreign_limit_index
      ( @parent.respond_to?(@plural) ? ( @count == 0 ? @parent.send(@plural).where("id >= ?", @start ) : @parent.send(@plural).where("id >= ?", @start ).limit( @count ) ) : @parent.send(@singular) ) 
    end  

    # The dates of 'from' and 'to' are inclusive
    def foreign_date_index
      ( @parent.respond_to?(@plural) ? ( @to.nil? || @from > @to ? @parent.send(@plural).where("DATE(created_at) >= ?", @from ) : @parent.send(@plural).where("DATE(created_at) >= ? AND DATE(created_at) <= ?", @from, @to ) ) : @parent.send(@singular) )
    end  

    def local_limit_index
      ( @count == 0 ? @resource.where("id >= ?", @start ) : @resource.where("id >= ?", @start ).limit( @count ) )
    end 
    # The dates of 'from' and 'to' are inclusive
    def local_date_index
      ( @to.nil? || @from > @to ? @resource.where("DATE(created_at) >= ?", @from ) : @resource.where("DATE(created_at) >= ? AND DATE(created_at) <= ?", @from, @to ) )
    end
end  