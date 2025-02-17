class MailgunService
    #生成されるインスタンスは全て同じ。一度生成されたらずっと使い回して(キャッシュのように)無駄に再度いろんな場所で生成しなくて済むようになる。。
    #include Singleton: 動的になる予定だから使わない。
  
    #.envからAPI_KEYを読み込む
    def initialize# constroctor
      Dotenv.load 
    end
  
    #書き方はこっから->https://app.mailgun.com/mg/sending/eigopencil.com/settings?tab=setup)
    def self.send_simple_message(user_name, guest_email, content)#関数内が動的になったらselfを削除する。(https://scrapbox.io/kazdb/%E3%82%A4%E3%83%B3%E3%82%B9%E3%82%BF%E3%83%B3%E3%82%B9%E3%83%A1%E3%82%BD%E3%83%83%E3%83%89%E3%81%A8%E3%82%AF%E3%83%A9%E3%82%B9%E3%83%A1%E3%82%BD%E3%83%83%E3%83%89%E3%81%AE%E9%81%95%E3%81%84(self.~))
    RestClient.post(
      'https://api.mailgun.net/v3/eigopencil.com/messages',
      {
      from: 'review_wave <postmaster@eigopencil.com>',
        #to:  "#{user_name} <#{guest_email}>",
        to:  "#{user_name} <kazumawada.jp@gmail.com>",
        subject: "📚#{user_name}さん、今回の復習内容です！📚",
        text: "#{content}"
      },
      { Authorization: "Basic #{Base64.strict_encode64("api:#{ENV['MAILGUN_API_KEY'] || 'MAILGUN_API_KEY'}")}" }
    )
    end
  end
  