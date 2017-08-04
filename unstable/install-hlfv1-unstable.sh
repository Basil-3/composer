ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ���Y �=�r۸����sfy*{N���aj0Lj�LFI��匧��(Y�.�n����P$ѢH/�����W��>������V� %S[�/Jf����4���h4@�P��
)F�4l25yضWo��=��� � ���h�c�1p�?a�,ϲl��O6e�'�y��o�vd�'�%�U�f�E��Q�C�V}ls�eC��*�ޥ( |��v�o�/ݑUZg�܃��\����6J�Mhi�نVd�`)�j�c{U�;�����MҠ�W-C�A�!�J��RE*��J�L.�~�3 �8� ݄-�՜���PqP�-��j��tGk�KU��%�iT�����9(�č��4ي���	��=@ C��>ff�9ѯ���fw�.kǰV�c��x�#���+l��Te͞ӆڃ��
����VZ�9P���<03��ki���e*���_>/䞩AL�.�n��)z5��a��#��"���6J����f.�1KV�-Tg1y�\^��qѯ�a�0M??S_�攙���9&\i�-��m�V���̥w�yH-���b�:�K�uS�դ�r%Q;Dԉ͞JĨX��*Rzvj��a�ɢ���V�h%_�x�^8��em��&5ߙ�K}j~�F<Ԅ�V��#�^��q���x��0�)D� ��)�_��?g�([Mc�{T��ܷ2�����r�6ㅸ�����<����Ͼ�4T=Ґ�e��@@?�&��T-����I��V)��)���/i����4ѯșf�h�G��ֆ_̑,�x:?��s����6��e��7e�����s������o���H;`���R������������u�����D�	3a�K��m@̈́��48�#�y>&��$��2,���C�0��ٟ�L�,� �R���it,�$�u:�5�T�5U��Mz$"f���et�m��׻m:�JW��h��m&銡��K6�;~�;jBm[u� "�Z����N�n���ɖ�Q��n��	B!�;�@��N@F��B#��mx5���'£�<I�/U/��c/������IL�ʠa⍹��6J�K�[�����ׁ����?���gc1�shM6����g [y����)��쀮�iDY[�g�!J��ru]���lj\�v��K�#E�{�_4	��__Rj����!�,��� M��q�:RDP��>@��e��l;4 �s?�b؈�jv�y-:I�TKE�s����ֹ[/�N��_�Y�H� ���^�Q̌���Jb������B���h���q[L�W�6�ULq�`��Z�q�=��cb^�Α��[�1��|��Kگ�!p0�A��ɀ��G��Obs0�8w�c��Q��ꢨ�#WuH!L{�@?�N��CV�{��ejPq���*`��h��i� �	�d�!�:9�i����+�@�����m�^#"�/j���g쌞n�%�� 4,(w_��F�jy������4�/T�O���PMC����K�9�?f���`X���� ~���6��/����\>P��������z�������:�<�5�,=m����eh4��ݬ%7<#͵,\���1�!�Ε��N��~�rVI�s�ս�!��b�7߲+�;����Wۘ$b,�.�����\�.�+�R���յ���@���������x8�G.��{~�5�\'�o��Of!b�Ne��JU,WϪ��T�Uo�zm�� ^�MV�~9Ӆ��{���ۅ����;&����9��B~޽��6��w�܂��0ޒ��FRwA��2��^Z4��{�51K���1Y����@��1b�+:�8�Y����Г\D9�������G;9?2�>�����2�o=����l����-�!7���?�2��_�m������zvW��n����	�4
�l�`������+�F�������t�6V���3��&�s�x���	������?����~3������a���?.L��� l�?k���ޅ:ڃ[��e֏��T��?��z�޴�ށ�`�v�O�� Tm��:���{��$�M�{h;�p���9q��Z�3"��t�����JL���"��U�� (�u�5���������>zL�h�ϫ��)4�ꁐ������� �/�an��7af������/�fV��������*��cD���G8�'��L�8`G�`0�3�ĥ��^}���ޡ؋��Y�1a6̌Jᦖ.t;�G�ݷ?����?/��s�)����������#(�ۥ����
,/�eIL�p��r��F������k�g���}�ל���߈������\��������Z�_����s޹"�<��p]��J��E��+�@)�~�	H��yU�Qȡ9�?���et�qȃ�Q͊���%���Zǰ��]#䊐[�Ƈ�ȭ�n���w�
���K��ֻc�A(�˪SU�cQf|�H��F3Y�IQW�Q�ypm�ш�:���D7�w�2�HW���а��g��^����Ǆi�O��o��:�WHV_���̹���k<j���ƚ���m��0�C���ꅋ�BR*W���YJ<�RQL��>�	 �7���qA�kj;��ML�p
L��=��H���١$���t�,U*b�ZJKU)U%���ԓ�a)W�z��p�/[��}9
��O�H����ٳ�T��{i)Y��4�K��I><ȝIh�1a{�œ2��v��~EJ�ʹ���$ހP.��7�wu6ե),�ϲT�+N�^�|*��T�;��	V3��!l��&^�*@7��;��g�ohn��7E��?��> ����kX�B�?������F�?>|��?b7z?�U��)��7؅+}7@��� "���������ѭaj��&�w@W���x�?�]�~�S@,����E�V������n1����^Q@K���?x���&�gM�����R�E����?؍�_|����A��C�W�.
+}E�%$pD��e�:8�z���Ȗ�����7D��Q�;qK B�B �w��m�+��7�)`Y��K��lt��.����������'0{F�5,�kQE^]�z��E髵b�J�٘,s��_V��s)�"����r���[|���ņ �����;h��І�ˣ��	gp���e��>���?�7���?>�m����}��Q�X6��c�%�s��� �P�҃�7���KQ�9Gc`����<���A�������3s߂��=�n�3`h���5�Օ�WV���� V�
DHL>�2����gS�FQ���y#e*�"��H��w	�X���M���!�~��C�[�@�M����^�G�m���g㬰���V��k%橧�s���E��?m�	Bts��Z�����3��7_��o��?����������/0�`��;-�UX>!�-^�I$b�F�㹸y�1>�HDyE�B"�6�;��������߯�銷�[�F�I4MME�2D��n������m=��9E��6,Gu{[���/��h�N��߿ں�����W��R o��[���o�a���/_��?[����[OQ�?�p^�&y~�~���g�fX]����R���(����;���9�e�X�������F��>�{���?⭆�Di�m�qTf�#-���A���?h�u���`�
D��L�һi[mco\�l|�!BaY^���-F��D���N����$x.
���iʌ��B�ٝ��h�qYN�<�Ԅ:��#�@�j[x��	aHJ�\��r5�ɥĪDR��\.�=O�D%����ΕŢ[���W�f$�o�!u��A�}�;0Ns�猄pʥ�G5�ݬ�֤d����ҥXN��uTU5�-vY�׈�q�c�"s.ּ<����<5�}�+��{�i�'��E�*��0���MO/%��m��x��O+�y�c.�Ӣ���W��󽹘���R,T�A�<��9�T�q�8휤1�����y�Q8����t��(+��k�R���.�,q[>>�+=�<�Jǅ���B�^�2nN:�����y�Rj�����#"�P4��8J�B����F5y�F2Y�&��f+>!��l*��H�"��Yw��"y�f��j�n����[����\pbi4���侞���Z��:�ă�ܬ��P���O�Az�X���B�;�a�=88�V���ȣ�@�6�)�9�o����r!)�v$�\)���u�1��Y��O撉��U�w�_����\*YL*+��aq�[�q���D�-�Z*w��탣�{=%�mTO �#_&��D������s��ǵA=�O5#�\�"Č^�Ͱidɔ�ܠ�������za�Pf�a�O���b�,��	�K��1����p䗼����Xq��O������5���1�' �H�L�H�[��܆�(�7
w\�﫻C�E�O���i�������,+l��v�a9WG�8�NH�S����5Y�m�Nf���m���6���|��P#	�ۈ=�NKb���oa1{�i}-���e��H��2�R�X��)��V,��Z�2#��.�|/����������,���Z}�˪�T�X��[-q��1����|z���L:F!���|��ԣ������뿰Y���l�w���x�y��ܜ��ߜ�]��Z2�K��Lw N�}�GJ<�B�⑒>j��XR&]���7����Y��mʇ��S�(eN3���|�֭gʉ�a�F�d��KGwz�x8`�:�`��ޮ�����.�Ӕ}�Q����h:,i���P^��������h|��xR�9�H�d.Y@���05�q�ʐ�E3L=ñ��鷡���r���Th��C�a�!�����.yH%�m� Ұ��*��2Z8�K��K␶AO��6��ƏZ"g��&)@>=��������(�=�h��ѓU}�H�C��k�+&T�,V ��EЀ�1 !HX�hЁ ���#QCH�H����dp|�yxF�wi._[��,<�����>*��9w:<������8���:����%a���ws�h�A"d!���Y��p-�>o�v-�Wa 
��k���>�8������q���I6
C'$�߾�0�B3�&�e��n{�OJ��m�����xl�jw�����n�m�����`���$��\�8 !�]�ZA�p����p���x3o�(������_����_U���0�(>`)�;��pp��f��`D��,P�(�˚h�	ys����lSCU���m��U貫oohI>�+�SN/��bk?���H>'M02��~Q��d�̌�36W�� �\䠜l��<t��/A�<M�Ǜ��?�г2l� ݓ�>wzG[g|�&�+?{��������/g$?�w%�nb	m~��C�΀>��M�!�j��m���T!���ɉb��@�)���ކv��n�~�0`�6t:E_�{0�̯Ӕ`�C�h
Q'�Ԑ��\�/
�,��[Ʒ�	�l��&��/�ϸxx��v���=�n@(�Cc���o��6�#����<����E-�c �j�j[�srE���ӑ���]ۘB�X�%��sS �!���c�����pt ��|$+s�1>"���m���S���Td��ɴk9���<������
��پm�[c��.N�)4*]}jB-���k�BJ��w��&ݹ��Tu�����:l�%e�-:d*(�.*��|~��]C�5����#��8��C��FG���Ʉ��Rhݪ�2����Wu����&��NM�-_�]�k#�Vt��I�Bodk�)xcsO5����k&ѷ����zh�@ү;���?�E��d�����W�!�v����>�V����?����s���������}b�_=|����!E�6E�&E,�_�y���w����~���gRh�g_�c�DF�JJ���D,���R/��e"�x����� ))���xFN�	������>��_O����O����٣�;������;}e�~+B|?��H�? �^!k���}���@���=����{w�������y�����V��1�j0�=�X�-J�~:�ܷ�b��$̳�Ͱ������Y�Z����D +�+_E V��:��Bm;���
�ူ�؎rSb;!���ȼ����Y{.���Y����V��� ̳K����"��B]�9�i<g��vk>�3i���z����Y��)6!��Gž4,����L�윍	��9�ߝ����v���|sڎf,�n�yӰ7/����7X�&5hW���}~yT\0C�t���&�IX�x��G��*��&;�M]��\�Xk����/s��A��3%_o&!a��=!�YT�z�J�
a��}���Ơ�"��@���C?h��1��7m�ϖ���jq�WkjX�y���B��"}·D����F<9��'Ƣ�z��y|���!�:ͫ���,�7�,�8U��y&�'��Z�����x֔�l{yT��Y>�w��$��M�N�Giz6��ben&G�X9����f#�Z���.{�{�6�~I�}I�|I�{I�zI�yI�xI�wI�vI�uI�tIl�\^�̻ě����&��_�(��}��p���g��%�,�;��-.������Y���В��%�|�]\��B�֮�@��v�'m`�=ܼ�
�s?��N��e59E��Tq�3��~�*�,-�i����B��x#�*D�$GͨpR��s"���d<��N���L�dBE��m�^�������y���to?Kg�@d�\y�<�DM=^� �liSݔ�'�X�vn_�~Jta�T(b��2I��j®�L��s�vK�h�D�*��� ��'�=c�raU�|��XK6;�ʤ[%�H��A�����!w����{��"��[�����G���[��7v^�}��rÿ`o7�s���e7��o��x�u6�e�<����u�OC��|#����}v���+����{���
����z#��_�˲�~��'�~�Q��$�B����?r��?x���<��?�֔��Д�`��y+=����T�֢̥�'I�׽����}~�����F7��k���rv�<�\�m�f:O�r������pLW��T�t�֦>��g�+��#�(-���:�Y9�alɬ�4�Q�1K*WHM��dq�W��Y��$����H��re�va_F����M�١�t�q޶�8m�{���0WT5~\<6��M��tű2i��[m�"�;mFms�;���`<��42�����cAf՚�d qˡ��aU����~�x?��@�8�h�`۹��o�|{����5G��4�p�Fk'�bP=�K��o��TDTNR��IFj$!�k�pд�BTA���Yc{T�ό�~\W�;�Q�ş��./��d�����⁽_�Vi�(P��@��.�y�9�	�R�K�*�:�ח����������/mȹ%}������#�k?aE.&��E��[�����0�w�X?�>>�J����wO�	��m�z0����>��o��rY�-�d��Z��5S�^-U���)N���65�r)�?hi��Xi-s6N0��bu���������W�QZ˞2�l���e�3��p�h�	�9'P�
4m9�r�dk6o�jk8�Z��y5W��T�7�O���GpN'tU"�4��c5�/
\u2���>-��Q�$]U�c�XhĦ<抍ԬH0�o�yG�
�z]�
��b<�/�{�lA�����52}jP�P����%�tqY{�B1�_]�e9��ʑ�ٰ6�h��@e���1�BTbK�u$���]G2�y�N�v	F��ؙ�]��	����t& N�<gRG��P����z��(�b��q�(;�7�z���đ�r�	���\֤{�hz֩5x5�-��1t:�h��	�*Q��l��|L_��3�H/��Qn�Pϣlq(�f�-������hi���#��g�B-��D�]vB@\(���w(L�_�i�R��DM�O��|ܢ;"}r��W�ِ��фB�}8�d�f0vcގL�P�&9�j�H��q}!v:�V�Qa�
w�2�ail�>}c��@\�n�`���E�7������c���w`u��s�Q��Л�Qӣ��e���Ӛh΋�ЎO�+�/�_edNMq1VB��"�4��I����e4��zz{�x��/��>��K�o��JZ�6z�x�y�qPD�ƓŇ�M�4��1��1�5�9��2~��>!�/ ���TZWH��ОpM��֧�/b�,������rN'X4;�?���<��9�,O�T�P"�K|��o��^��E^�tn��Tv�ל�����s��Od�o�şk��E���?ģѯ��������+��%p��wӤ��)�j���ϝ\C�y�ܙ�!)���͗�>$F��a���d�
��L�P��Ή��hW�3tT��n�ww�!A��&�i���;��Wצ�����w���'���0�*At�z^���R��4�u=�ŗ�Y^S�_���Y:��pK%�����"���[�V��uÁ����b	� �\ �?���a����(�� �s��~��L]��3A���`����1�7���q���m#�����.�51���$y�4��T�ɑ}jv��4���ԑ�4�<��_P�Wh5��2`	� �t��d�J|L��'X]T�`�2���Kt�lC���§��=P1�w������y����rn<�L��sER@��j���Y���6��49ׅ���w���m��������\�46���C8j���8X!�"tb��Ɣ��$�2(0�N�QW�����s�$��T��ٝȾܺ#�;����M�o"lo.z������}c��lX؏���z���aS�����"��+Nx��0M|ֳ
�hc|l�t��h>��Ŧb�4�Zc�"ZW�����p�Fb���p,��Fʡ̭5n���"rؼ�p�BR�3����pY���Wۀ��5.�oD�7�c����$��G&p��l]`�Һ[�&�������~��)���w���p�I�r��8�
"$���x�/0���Pπ�;�1`N���0�wo z��N�"��S�?�^�{٬۫.^� ݵ��`�P����dTO�`()=�Cm#
H	��|�.�d�\�VIP�5�&�nn������F)�k��W�1�5����bf�`���m@�ce2�MA��@��qs��B�K�%(�)���XfaA!;���/�+!*t½a;x�	D�^�h@�͒WU\U�`e��"`�n��4)0��Uq�6�lTo�?x��#i/|t���cƽRa�n��*T� �5&k�v����7v%�%�\�!=9��L�r�ºf�q�iH�y�8� V@Yݣ�� �rE��䫇�vh�_�M��6�4M��t��L$]Y���<74�h���N��%p���N(-�D�w1�n�-n�0R,ۘ\��)�t��~�ոp���g��'�f������ް�_�����]���2����HES����Qg���翾��q��F?%4���l�sñ����Ûܕ��3��F�����i�>EWc<+V7���;(�dlp�c����i�bKm���ʅ^����
_M[��?E'���k
:��/V�FeЋ%�R )��D��)�D/��u�J��S=
����g��ԓz�$���
�&��9p,�{���{����^���>��K~�Y'�%��T|iȍ[��C|�9<���XR %@��H<I�@��J� @2�(�H:�Vb@�� %��(�B�$P�`ȧ�s�!�;�ɧ�X3�����/<y���M[�v�{�٩�Qn�(���&[�o!�Fe��>x��V�,W��:ϕ�:]:-U�%�+=�i�^N�7D�L�l�k4�Ep|�����'*�3���v����/ٲvE��tIhTy�Y`��:jt�Յ*ͱ�څWV����TF�3acl�U����I7�jV*��t��ֵ�;�b���I�3s�2���}q�z�Z#{��;𖁈p��M	�ҷ/�l�W,�\>�/�z��V��y��?�r\}c����͗�vE�(�1��:�pʕ�j�/�Ϧ#m~��V��L����� �9Q�pH^������q�եͺ����Z�4�l����eNlU�Gl�3O�N��v�]�gM�"Lu�Wi�pQiP�}mYu��aކH���E��ܳ,��e���V��˸mry�.SM�/{W֜��l��+�;u��[�U}� !��҄�'	����`H����N��!�"�mi�ս�WK"�[��/�-_v��+��x��m����4��3L}�H��c׹c?z���D���=���{�5=[�������?�jer�W�u��Q���Q��׳��ٶ/�xK\���_?���|swZ�%�܀_��;|�)�����3�ϻ���"�������_>����us`.A�+�Ф@�������/(����}@�|�+���O�&X���C�oY��iX�����n��I��F����y�o
@ ����i�$���i�|������T����'E_�OT����_���[��w$ ������j?S�#�K�B�qw���CT�/�$��bR$G�Qg�`)2
FƑJ�H�1/��	N`�「b�������������n���B�o���1��<�3��e6Y��nyW��^w�)�L/����k1�a����?M��+e���G=H�H����eb���=��ۍ��N��p�w���O�C8S[�>�n�^g;���CJ�~�O��x]�k?���g������������'�>P��[��� ����i�N���GT����������?�������
��K�vї�S���p������$�������B ���?��������� ^���/T��*��Y�'K�7�O����N��	s:���w�Gݩ���$�@��>����ϭ������0��- 8��u��IQ���K�}���ŗ�O��Ƣ薲y]��\:us���TH�gh*�������xO���5¬�o����~o������XV��o��|j�$f6M�CEg��d�������q�YNu����f�N�)�Ɔ����<��J�n�;��, ƧJ��;�&��Վ˟�ȍ���>��>�_�����|#�zR�3}ו7�fAxu.�X~o�ձ9\�F����aߧz�N�sw�)C_Ǒ8H�;�&M�ߖ�5��Q�O��.Q��`������u��R�����l�0�qW'�)�R���%��p�_0��QH��?��Â����0�����X��w��(������O���O���w��0��$���� ����X��ý�=�s��(��������//��w���5����>f�{>i�����W��}���?�����M��a=���~�]s�BI���q�Q�f�	2{�YA�\E�M���Z�B���MC1��RO�&.7�>?b[Ce��Щ.;�e�zz����X6����=�)�y�!��*��+��c|��������vlc,7�	];�D����~Z���2�V�r8��Ca�X�b��Y%y"����wG��*JO<���I����42$��qҪg������_������?
�
`��f�1�V��� ����8�?��^����?����(��p�QQH�Tĉ\���IR�1���b2<��BH3AH2!r��dL�_����4������5����j�+e�'�U*�'�^�R���i�l���>��ۢ9�=��}��q��7ܣ��Q�J�Mo;��>\�Ƌ%��VВ4�'��6�d���`]N���햝��G5��-p�����8��gs8�-8���,��
��������/�'��_q����β����~"$��:#^^K�;kn�p9��i�9q��=�z��[zOM���[ǔ�Kk�^��SyL�rg���c�YBv����+��9��<Wj�]���9��a�o�2�`���� �{-���i������'�����O �_��U�������� �����h�"�����w�����%����/����6�����y�(}��7��Ѵ���=��W���8���{f ��1��V�ޝp��a�7��]�J\� �8@����qr���VL�Z�3r�mGD�T)+�zn4+˩�h��z
�RbuzM�1���$pV���z�%����T���b�xaN$�}G���ǯp���~_�2�v+Jn*�x`�$zE9�OB��b`@���Z9IڱU��-�S����iA$�(Z��R�u��&�=6��ZY*so`����V	e����I�l�j����֕���P)���2�G��\+~����u:m5�2��r�Zݣ���<[����6f_̓�bQ��q֭76#�F����,�?���?���_�X����������p���s���H�����[���_���� ������/��������D�Q��Ɋ��E�lH����<�J�@��3~]�A�MG��BL��Cc����N�/'�����_��f'c�r�����7	�^OV���ck�cO�e�+�����։�>:Ή����Q��ݦ&�Ky�X.���,���E���n-��O�.;W<}�wv5�ui��ߪ�U���,*P��Z��S��?��A������C���#�X�7��y���?
`���M������b�8���h������!r��/?���1*��U�wZ��
���~9�կ��֮��Y�cTV���@����ܾ��O��k��T���֘xO���5�=�ߗ�l⧵�y޷����s���j�#^������A�����t�ު���d��O����D�ӭ+�es��	�;��Q�#g2�L��u���#��;����j�7�ݮ�4e�J\�r����������b��;A1��v����جN~��%�
oN�:Wc}w[��Ȧ��i��	UO6Aw�����T/���\�,�nޓ�jTN����jaՏѪ��׾n�$�b�3km��UV���vd�˲��wV{0�� ��0�W@�����^v�-h�
�q����o��?$��o����o��������y
) ,����8�?������ � �����/�A����������Ş����&A���������K�����@��o����� ��I�6�g��Q ��/��m�h ����0��(��`Q0������N��$�����@ ����ܝ�/P��x�?�C�*��U��� �������w�G����0��R  ������n�?��#�����C�����$ �� ������?0�(�n�����a����5�����?0����� ��� ����w��?"�/�$P�_ ������7�����X�?��#�?����������C�w�G���?�@���c���1�� ��ϭ�p��ٽ ��'�����X��
"C�#Q�G!����L�P/F>�y"�)Q�|_�Y��M?��{��3<�A�&�ow��9���>|����s�)�,U�d�_r�����7�Jc5)K�Y�^K�5��j>��+Z�:{I���Re��ݫ��Z����N_J��P�R'ۛ�G����<��^��Nu�_��ծۢc����M��%�E��㕩~�n�T�3����gq(x���p�[(p��!�+X�?�����s�9��E_�O����;�vȘܡ���y��l�����jmڎN���_V��!;�k}�?��x�9;gn��l�ԥ�۱M�;��$a�־���P16ew�S�m�zׇ��ioL��b�u9�I�a��r����k���3�򿈀�����ۿ���	�������A��A��@���X����^�����%�׺��U��?���1j_��Kg`�ӽ�$��/���w�mw�v��)^�Z��:�x���n��ٺ�K�~&mx֩�AB�(���`ӟ�4
;NcOU�I�';)�o���1���I��Z�q�L�5{b;��o�fu��ڮ�<^���u��K���V��T���VI�r���S�$^lhѾ\+'I;�����"uʶ�X9-C	k�b�Vj�n#�meS�U�&w#i��HS�`0122����C�����N*U�3�!O�3�j)5��AE�l��"I�Wɺ6�J�n��ʣ�6���^�w��j���[���x��/M
�_��h8�E��X���_������?��Q��O��F��~���nP�-P����?KR$�?
���4Iݞ����(���|=��?�������g��!��/����������i��z9�;���f4���.����Q�d���C������C�M;�����9�ֹf5�������xJ�_s~v�'�g�y�<u�J��\R����ŵ��ֶ�ߕ�J>fZ�k��T��RP�ԗ����.���i�D�k��]��Ur���T�iq�َ�����]S�\���U攬IY��uW�q�����~B���vE���+��h�k*�}�Oǹ���J2�/?˚�~J��7w�/ٵ��^�HK쉢*��v7LI�7�S��T']�vRߗk6W���!Զ��g�Z�Y�9�j����D��͉#*T��9;8�(.��e�+ҡ-�;���Z9��H��[���9ɝ�rS��}"=����c��¾䴴yK�{�~O�B�q7�p��h��pd�S�#�bi_1!�_f�P�,M��h
,#�|F���8�(?&C*�����m��Y�A�����OFr��vF{��нh;��?���C��9c�cO���o�ʷj�x�\����->���$�p��]�����x��(�����C�?d�0��1�����q�����_�t���_�F&�[�t�����҅΀�F�M������y屠NϹk��`#ޖ��})�#ޓ�����W����>��ZOy���񺼟�L2�f+'�Rv���K��ޕ6+�m���
�^ŋ���� �vtu  8�CGG �
"������̛�U����t����"e����{���3�U��=rzh.k.�麘��e��z�i�4˻����G�ɆUsz���b9��L�a?�[����~ȝq?Uήñ��cS*�2�D��ݱ�u<���pkOYy�>�M����̌Ӻ7�4|d�]w�c#cƐ�Y7	Q,���~�Ǳ�4��������~��Q�������kM�B������$3�������������� ���Ri���Zű�Y%�t�O��Wc��Q*�V�*���]����8�l���
��!������_�������{�����%�h���8�Fȱ&̍M�|$a���.��#���e���eK�Z�o�-0���x��?5����?��a�/A�%j�V�a���@Ͽ����
���?����_�!c���@�tPa�����v�38����K�?|���}X��?WPY�������nh����������mN��?�>_�Q<��뺏u�c_M�D9���J�>?uV©S_�:�m�M�l��OVB�:s�|���u�
y^�r��_.�-�ŵ6�����Yx!�}�J�ZF�3{��R7�V��K�hߙ,�}��Z^O���7�gq]'n�2�E<p5���]_�^��Wkt�a��|�鴅�����������pY��o�lܼ���8��[֚��6���=R����`m�}��ڻ���m�Bn��'/)���ar�A_�ٶ�o�jϐCiLף���!sP�bʱ��m�qF��Z�Y�����,0��{�8�5_+�#�Om���G�o��(������?� ��_W!�/* �l�W�����C�����C!����O����L ����	����	����ު���!�B����E�����?����o�ߒ�0��	������������[���տ�K��!������$�6(�37�����������
������N�/��f���?���������?�����O!O�_�����;��w�����@A�|!rBV�����-���	������qQ�������L���������c�B�����?2B�*B�C!��������!���?���?��?迬��B���[���a�?7���"'"���H���3�?���?��C���w�`�'��Bǂ�����c�B�?y���2A1����B!������������(���h���	y꿵q
�m`@�� �l�W���7�?���
��:MกiUfI�z�$z��5� uS]��*eL��u��MS����4��Th��އo����Q��з�?��g�W�o O�������_j������ĝvҰM֒�%�yN�b5��-�>�}�W��v�s$;�Ju�&���:�pMbE�����NW�ڞ���I���D�ۍ�!���c��'k��K��(=Pn�����߳D!�q��^e��;����y���Qm��}�����T�^0������W�m`ַ(B��_~(�C�O~ȓ�/����y�����_~����ZmBڋ�1Eg��L��t#����̻<����ޚ��_S����Nw�v5=�����l�R8�G�'�M�*v{�Ө��i���ʉ��I��n�L=uI���B[|���⿯E1��
���<�]}҃�Q�F(D�������/����/�����h�Q�G�7������_��{�ݏ��۱�@�Ck���đn�X?����]�}��:'r	��5�����!�G�XLf��v0�SFu��贷��T�&ˮ���L�#���̌��b�9��~-�d[a����: v퍺�+j_�׫a��(����ܮ͒uvI�O�J���峖����d�%�\_�?�)�s����^g����RD ǉ��˛ۂRg�+5�kɇ��|r��D�X�=�;�.�p�/�b�`�����8�n}�ƭ#�<Ϋ��#�X=��0�侘�3lW�$ڝ���?�t��%L�6�*;����5���p
����[��/@�GA������?�&��¤������(�3w���,����x��}B� ��ϛ�	�F�S��r���,�xp ��������������E��n�G�?���O������LP$�����9�Ǆ�	�����������(����������?X2W@�������?���?,��
�ӷ���d�/�����c��U�Q�p=nz��`F/M���Ce[���b���#��k?��
��j�ϵ�!��#-�@���w���������:��|]�o��D�F�;�b���<���~�W}�F��项��x��b�6o��-����,�j��R$V��y把�Ⱦ2I�~�o�����"w�~UM8�Ǣ�ÎM��O���v����T��í=e����6��u��33N��L��=v�	���C�g]��Y����]�ci&gmkݍ������6�6�1ʋ�ך�+�Du����If���B���n�]��Z<�xD@����������H���F2E!��;�_��g���/����|��rB����"�y7�C������
��	��;G� �[��?���/���z�����Q�M�͆�#Ǔ��c�ڳ�5�/Z�}�?�%�:<�9��`���ӵL�j ��?>� T�N�N��*a7�r]�Q��*�b�w�mY�ww�1�����U�~����nW&6J��Q���꫚��&���  i�_�@�"�?��l<`ek�ܔ��}\f�h����d�c&!Q�Űv�:���y��ۑ�c��C�U�tԎC��h���3�߉5�����oF!�~g�����������	��[���+���
�(��5���
c������j,+�F��Ѥ�S�IX�fP�nb*��&�C�*C,i�}�V��E��{�B�6�����3tH�����9#	;�����&�a8[����yT+_��<�O��6VY�Ub���`o�7DZSrl�VEU;��R��U�(���9GI8/�t��X:	�O=lՏf���ע�?��\��t����Q����P����ܐ;��,���y7�C���_~���?�o��J�z�¡K��kR����7�"�C����N��]�?zȟ��x�#|߯����#7(��B��4&��L�A������V�+Fԕ4��|��6��?��&4gG�$ ��Z������R����#��_Wa�Q��/���P��_P��_0��/��Ѐ�����*��r��4��Q��lݧ�ޡg�D[M���nR������{�o�@���(��p�n:کj��;�_V�8�O����k[4&��ȧ�F+�jQe�Mg��v+]�\�gJm5u?T�^]�;�.�Y������CR�ǩl���<��^�f<������`(�����m��z�^����Dr��5n�ժ�EcM�
2��G�kn+Q8ciJ��9,F�˛�\�V%?��b�lt��TH��Ƈ}��z��8�#��ӄ��(��K:�L��g{+Z!��ic-Nsdnc��Z-��)}��ZԲ�>=�	��Z��������y��	�?���6�����,������_��L��'�O�t������2�R����(�{��y���:�n¨GD%��2����=v����޴�\���������t6F���t/RAJ>&t�һ�>�������Ӈ��;��IKw��y[�<cs=��l_�T�lL~���k�^��~�R������D����s���?��?�	:��������@5�C55��%��D��W2� �JFl����񢒺٤O��z��		����8��U+E�Q��A`$G.��УmpB�����~�WI_��������_9v�x?�������S�?*��%?^&���"�o�59�o?}x�d��B�<_6�ޙ����tr7��6����{��n��g�&mcn�R����XZFP�<�h[z~B��OW��o�K��N�+�{��Y�MBQ��v�w�	ýQ��T�#v0z?��Bw<��7j�~��w5#����m��_��n��ݽ��]H��u���垓k0��o��,�u����z|I���ݶt'��/���d?'״�Q#�Q�c�Wv�G���*[���KJZ��M<}r��{�0x���nG�����"�"�}��e���?)=৯j�Uz���o��+K�OO���C�3    (�zao � 