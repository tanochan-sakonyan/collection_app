import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mr_collection/generated/s.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
          title: Text(
            S.of(context)!.termsOfService,
          )),
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
                          "【利用規約】\nこの利用規約は、集金くんアプリ（以下「アプリ」）に適用され、Yuma Ikeo（以下「サービス提供者」）によって無料サービスとして提供されているモバイルデバイス向けのアプリです。今後のアップデートに伴い、一部の有料機能が追加される可能性がございます。 アプリをダウンロードまたは利用することにより、あなたは以下の規約に自動的に同意したことになります。アプリを使用する前に、これらの規約を十分に読み、理解することを強くお勧めします。アプリの無断コピー、変更、アプリの一部または商標の使用は禁止されています。また、アプリのソースコードを抽出したり、他の言語に翻訳したり、派生バージョンを作成することも禁止しています。アプリに関連するすべての商標、著作権、データベース権、その他の知的財産権はサービス提供者の所有物です。\n\n【サービス提供者の責任】\nサービス提供者は、アプリの有益性・効率性に最大限注力しています。そのため、アプリを変更したり、サービスを有料化したりする権利を常時、いかなる理由でも留保します。サービス提供者は、アプリやサービスの料金については、必ず事前に明確に通知すると保証します。 アプリは、サービスを提供するために、あなたが提供した個人情報を保存および処理します。アプリへのアクセスとあなたの電話のセキュリティを維持することは、あなたの責任です。サービス提供者は、電話を脱獄（jailbreaking）したり、ルート化（rooting）することを避けるよう警告します。これらの操作は、デバイスの公式オペレーティングシステムによる制限を解除し、電話がマルウェアやウイルスにさらされ、セキュリティ機能が脅かされ、アプリが正常に動作しない原因となる可能性があります。\n\n【責任の制限】\nアプリの一部の機能は、インターネット接続を必要とします。接続はWi-Fiまたは携帯電話ネットワークプロバイダーによるものです。サービス提供者は、Wi-Fiにアクセスできない場合やデータ容量を使い果たした場合に、アプリが完全に機能しないことについて責任を負いません。 Wi-Fiエリア外でアプリを使用している場合、携帯電話ネットワークプロバイダーとの契約条件が適用されることをご理解ください。その結果、アプリへの接続中にデータ使用料が発生したり、第三者料金が課される可能性があります。アプリを使用することで、これらの料金、特にデータローミングを無効にせずに海外（つまり、地域や国）でアプリを使用する場合のローミングデータ料金に関する責任を負うことを承認することとなります。もしアプリを使用するデバイスの請求者でない場合は、請求者からの許可を得ているものとみなされます。 同様に、サービス提供者はアプリの使用について常に責任を負うことはできません。例えば、デバイスのバッテリーが切れ、サービスにアクセスできなくなった場合、サービス提供者は責任を負うことはできません。\n\n 【LINEを用いたメンバー取得に関して】\n イベントを追加する際、「LINEグループから追加」を利用してイベント作成を行った場合、LINEグループID,LINEグループ名,LINEグループのメンバー情報などが、集金くん公式LINEによって収集されます。これらの情報は、LINEの利用規約に基づき、24時間を経過すると削除されます。取得した情報はLINEの利用規約に基づき、取得後24時間が経過した時点でサーバー上からも完全に削除され、復元することは一切できません。削除されたメンバー情報の紐づく支払い状況ステータス、支払い金額も同様です。ホーム画面上部のメンバー自動削除までの期限をタップすると、グループ情報,メンバー情報の削除期限を延長することができます。グループから取得された情報は、サービス提供者によって厳重に保管され、アプリ外で利用されることはありません。\n\n【アップデートとサービス終了】\nサービス提供者は、アプリをアップデートする場合があります。アプリは現在、オペレーティングシステムの要件に基づいて提供されています（また、サービス提供者がアプリの提供対象となる追加のシステムを決定することがあります）。そのため、アプリを引き続き使用するにはアップデートする必要があります。サービス提供者は、アプリが常にあなたにとって関連性があり、またはデバイスにインストールされている特定のオペレーティングシステムバージョンと互換性があるようにアプリを更新することを保証しません。しかし、アプリのアップデート版がリリースされた際には、常にそれを受け入れることに同意するものとします。サービス提供者は、アプリのサービスを終了することを決定し、通知なしにその使用を終了することがあります。終了時には、サービス提供者が特に通知しない限り、（a）これらの規約に基づいてあなたに付与された権利およびライセンスが終了し、（b）アプリの使用を停止し、必要に応じてデバイスから削除しなければならないことに同意します。\n\n【利用規約の変更】\nサービス提供者は、定期的に利用規約を更新する場合があります。そのため、このページを定期的に確認して、変更があった場合に備えることをお勧めします。サービス提供者は、利用規約が変更された場合、新しい利用規約をこのページに掲載することによってお知らせします。同時に、アプリ内ポップアップでの通知も行います。利用規約更新後の継続的な理由は、更新された利用規約に同意したものであるとみなされます。\n\n【お問い合わせ】\n利用規約についてご質問やご提案がある場合は、遠慮なくサービス提供者までメール（"),
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
                          "）でお問い合わせください。\n\nこの利用規約は、アプリプライバシーポリシージェネレーターによって生成され、一部をアプリの具体的な機能に応じてカスタマイズしています。\n\n"),
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
