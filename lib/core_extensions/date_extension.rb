class Date 

    WAREKI_ERA = {
        'M' => '明治',
        'T' => '大正',
        'S' => '昭和',
        'H' => '平成',
        'R' => '令和'
    }.freeze

    def to_jp_date
        wareki, j_mon, j_day = self.jisx0301.split(".")
        gengou, j_year = wareki.partition(/\d+/).take(2)

        gengou = WAREKI_ERA[gengou]

        j_day = '8' if j_day == '08'
        j_mon = '8' if j_mon == '08'
        j_year = '8' if j_year == '08'

        j_day = '9' if j_day == '09'
        j_mon = '9' if j_mon == '09'
        j_year = '9' if j_year == '09'
        
        "#{gengou}#{j_year == '01' ? '元' : j_year.to_i}年#{j_mon.to_i}月#{j_day.to_i}日"
    end

    def j_era 
        era = self.jisx0301.split(".")[0][0]

        WAREKI_ERA[era]
    end
    
    def j_year 
        j_year = self.jisx0301.split(".")[0][1..2]
        
        j_year = '8' if j_year == '08'
        j_year = '9' if j_year == '09'
        
        j_year.to_i
    end

    def j_full_year
        kanji_year = self.j_year == 1 ? '元' : j_year 
        "#{self.j_era}#{kanji_year}年"
    end

    def j_year_month
        "#{self.j_full_year}#{self.month}月"
    end

    def self.parse_jp_date(jp_date = Date.today.to_jp_date)
        puts 'parsing date'
        if jp_date.size == 11
            puts 'right size'

            jis_era = WAREKI_ERA.key(jp_date[0..1])
            jis_year = jp_date[2..3]
            jis_month = jp_date[5..6]
            jis_day = jp_date[8..9]

            puts 'string to parse'
            puts "#{jis_era}#{jis_year}.#{jis_month}.#{jis_day}"
            puts 'parsed string'
            puts self.jisx0301("#{jis_era}#{jis_year}.#{jis_month}.#{jis_day}")

            self.jisx0301("#{jis_era}#{jis_year}.#{jis_month}.#{jis_day}") rescue nil
        else
            nil
        end
    end
    
end