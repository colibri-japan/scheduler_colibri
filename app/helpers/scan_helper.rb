module ScanHelper
    def scan_status(scan)
        if scan.cancelled?
            'キャンセル'
        elsif scan.done?
            '終了'
        else
            '読み込み中'
        end
    end
end
