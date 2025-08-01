import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mr_collection/generated/s.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF76DCC6),
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 173, 252, 235),
          title: Text(S.of(context)!.privacyPolicy)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  const TextSpan(
                      text:
                          "このプライバシーポリシーは、Yuma Ikeo（以下「サービス提供者」）が提供する集金くんアプリ（以下「アプリ」）に適用されます。このアプリは無料サービスとして提供されています。今後のアップデートに伴い、一部有料課金制の機能が追加される可能性がございます。\n\n【情報の収集と利用】\nアプリは、あなたがアプリをダウンロードして使用する際に情報を収集します。この情報には以下が含まれる場合があります： \n ・あなたのデバイスのインターネットプロトコルアドレス（例：IPアドレス）\n ・アプリ内で訪れたページ、その日時、ページに費やした時間 \n ・アプリの使用時間 \n ・モバイルデバイスで使用しているオペレーティングシステム \n ・LINEのユーザーID \n ・LINEのユーザー名 \n ・その他LINEログイン及びLINEを用いたグループ情報の取得によって収集される情報\n アプリは、あなたのモバイルデバイスの正確な位置情報を収集しません。 サービス提供者は、提供された情報を使用して、重要な情報、必要な通知、マーケティングプロモーションなどを提供するために、随時あなたに連絡することがあります。 \n\n【第三者アクセス】\n集計された匿名データのみが定期的に外部サービスに送信され、サービス提供者がアプリおよびサービスの改善に役立てます。サービス提供者は、このプライバシーポリシーに記載された方法であなたの情報を第三者と共有することがあります。 サービス提供者は、以下の場合にユーザーが提供した情報や自動的に収集された情報を開示することがあります：\n・法律に基づいて必要な場合、例えば召喚状や類似の法的手続きを遵守するため。\n・自身の権利を守るため、あなたや他の人の安全を守るため、詐欺調査のため、または政府の要求に応じるために開示が必要であると正当な理由で信じる場合。\n・サービス提供者の代理として働き、開示された情報を独立して使用せず、このプライバシーポリシーのルールに従うことに同意した信頼できるサービスプロバイダーと協働する場合。\n\n【オプトアウトの権利】\nアプリをアンインストールすることで、アプリによる情報収集をすべて停止することができます。モバイルデバイスの標準的なアンインストール手順や、アプリケーションマーケットプレイスまたはネットワークを通じてアンインストールを行うことができます。\n\n【データ保持ポリシー】\nサービス提供者は、ユーザー提供のデータを、アプリを使用している間およびその後の合理的な期間保持します。アプリを通じて提供したユーザーデータの削除を希望する場合は、"),
                  WidgetSpan(
                    child: SelectableText(
                      "tanochan34@gmail.com",
                      style: DefaultTextStyle.of(context).style.copyWith(
                            color: Colors.blue,
                            fontFamily: 'SF',
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                          ),
                    ),
                  ),
                  const TextSpan(
                      text:
                          "までご連絡いただければ、合理的な時間内に対応いたします。\n\n【子供のプライバシー】\nサービス提供者は、13歳未満の子供から意図的にデータを収集したり、マーケティングを行ったりすることはありません。 サービス提供者は、子供から意図的に個人を特定できる情報を収集することはありません。サービス提供者は、すべての子供に対して、アプリやサービスを通じて個人を特定できる情報を送信しないよう勧めています。また、サービス提供者は、親や法定後見人に対して、子供のインターネット利用を監視し、子供が許可なくアプリやサービスを通じて個人を特定できる情報を提供しないように指導することを勧めています。 もし、子供がアプリやサービスを通じて個人を特定できる情報をサービス提供者に提供したと考えられる場合は、サービス提供者（"),
                  WidgetSpan(
                    child: SelectableText(
                      "tanochan34@gmail.com",
                      style: DefaultTextStyle.of(context).style.copyWith(
                            color: Colors.blue,
                            fontFamily: 'SF',
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                          ),
                    ),
                  ),
                  const TextSpan(
                      text:
                          "）にご連絡いただければ、必要な対応を行います。また、あなたが個人を特定できる情報の処理に同意するには、少なくとも16歳でなければなりません（いくつかの国では、親や後見人が代理で同意することを許可しています）。\n\n【セキュリティ】\nサービス提供者は、あなたの情報の機密性を守ることに最善を尽くしています。サービス提供者は、処理および保持する情報を保護するために、物理的、電子的、手続き上の安全対策を提供しています。\n\n【変更】\nこのプライバシーポリシーは、理由により随時更新されることがあります。サービス提供者は、更新されたプライバシーポリシーをこのページに表示すること及びアプリ内にプライバシーポリシー変更のポップアップを表示することで、プライバシーポリシーの変更を通知します。変更があった場合は、このプライバシーポリシーを定期的に確認することをお勧めします。継続的な利用は、すべての変更に同意したと見なされます。\n\n【利用者の同意】\nアプリを使用することにより、あなたは本プライバシーポリシーに記載された情報の処理に同意したこととなります。\n\n【お問い合わせ】\nアプリ使用中のプライバシーに関して質問がある場合や、取り扱いについて質問がある場合は、サービス提供者までメール（"),
                  WidgetSpan(
                    child: SelectableText(
                      "tanochan34@gmail.com",
                      style: DefaultTextStyle.of(context).style.copyWith(
                            color: Colors.blue,
                            fontFamily: 'SF',
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                          ),
                    ),
                  ),
                  const TextSpan(
                    text: "）またはウェブサイト（",
                  ),
                  TextSpan(
                    text: "https://tanochan.studio.site/",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        print("URL tapped");
                        _launchURL("https://tanochan.studio.site/");
                      },
                  ),
                  const TextSpan(
                      text:
                          "）でお問い合わせください。\n\nこのプライバシーポリシーページは、アプリプライバシーポリシージェネレーターによって生成され、一部をアプリの具体的な機能に応じてカスタマイズしています。\n\n"),
                  const TextSpan(
                      text: "制定日：2024年12月1日\n最終更新日：2025年7月28日",
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
