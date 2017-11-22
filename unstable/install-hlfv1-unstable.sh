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

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d

# manually create the card store
docker exec composer mkdir /home/composer/.composer

# build the card store locally first
rm -fr /tmp/onelinecard
mkdir /tmp/onelinecard
mkdir /tmp/onelinecard/cards
mkdir /tmp/onelinecard/client-data
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/client-data/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials

# copy the various material into the local card store
cd fabric-dev-servers/fabric-scripts/hlfv1/composer
cp creds/* /tmp/onelinecard/client-data/PeerAdmin@hlfv1
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/certificate
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/114aab0e76bf0c78308f89efc4b8c9423e31568da0c340ca187a9b17aa9a4457_sk /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/privateKey
echo '{"version":1,"userName":"PeerAdmin","roles":["PeerAdmin", "ChannelAdmin"]}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/metadata.json
echo '{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { "url" : "grpc://orderer.example.com:7050" }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://peer0.org1.example.com:7051",
            "eventURL": "grpc://peer0.org1.example.com:7053"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/connection.json

# transfer the local card store into the container
cd /tmp/onelinecard
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer
rm -fr /tmp/onelinecard

cd "${WORKDIR}"

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
� %Z �=�r��r�=��)'�T��d�fa��^�$ �(��o-�o�%��;�$D�q!E):�O8U���F�!���@^33 I��Dɔh{ͮ�H��t�\z�{�PM����b�;��B���j����pb1�|F�����G|T�$�����cB<�p���FpmZ <r,�����f���E����&X��FVWS���0 �c�����/Á����l��a.��ڰ�Ӛ��t�6���E혖c{$��n��$��9=�j�\ա�;":s�e@}Pl\��>.���K�:�Y�RQ7D:��Ƚ� :�K��?����H�_�E���]�)�����w�T�gdiV�n�˃��t}��@�_��x�t>.
�r�_<�!RӌH�M�6]KA�]}
�~��E�Z��")�wޗ���T����X�㏠�S��{݄*��`Y��_L����;?��s�R�K���a��+�:@Ȓնf��50�$pg��K�\�K���a��w����|��6�{�A��k�x���Lĥ�/. X���&`�v����D�sᄗ�"[������ ��,P�i6pL@Z�;�M!����ˇ9P7-�9!�촑�`��v@ǵȞ�Ϸci]�a��"�d!��9��ǩt?�u0"ACsh9��Z:Ii:N�ތDpNӭ����G嘦n�Iy\��2���4-Z�@R~	O>]S�aS�2֚&
	a��j�~ϴT��D
0HY�M��4�fRlSwI��D�w�������5W������E6���w@(D>Ꚏ@�����xT)��i�A��EC��P�S4��iHj�q�yY|X�k7�����$&rep	�C�3�˕�3��d]O�Ӂy]����s'�?._�������<��u�P�$�&t@K�u X�mvND�rC3�C�����s�0���S�!бA��3F��7Ě<���`Y��!i�9)M����1۫|X ~^����urT�q�rR�L]�̅q�0�]��{�Tr��6l�6�A�N�^�V���=%��Aa��Ph�����o�ق{�nX#�d�zL*��|���
��0p�UfڪN��`}|��Ty�#�4�>m�@�����q�`��v��:��O.��]͡��쪉���&n(�9(G��A�Hq@��)M`R��,�}�����	~���:9��Y}������m>�7�`���;Q#,W)���$�gT�^ P�Ny�ŋ��!��4/���a<t�9~:��¨���K��
S�2��m����cRly��X��|�0E�G}yO<f�?/
�I�����B���ң}�:�6��K�Xc���1v�-X�l4ײ<i`�Ǵ�L:W���ل�����˩R�+���_�c������^�/׈H�V�c#7+'K����L���/<?�Y;�;� 4����ul��n�0h��.�b�3��l�~6�mt=ML�xk��YXX�\��\�K���\>�_�\/��4�y	<��,�~v�
c��xɫ1-����7\(����I�� ޼�So��Z�{�	�-�u�%��k�b����*<)K�dFE't�oV<���d#��o�E��a�Q��Q�~Ekص�O��2ɞ�<��,�O�]��!�b��p�������+�M0u8-VQ/8Ou�l�.�0��o�Y4���a��-�>�Y��I�/�����g�|����贁f��u
�١����B�	�����97L��	�i~w���sR|������řk̚��O��XT$�����_ܶ��0k���G'��h4�\��↛v�-�ȲLkt,�p��v�f�B]��#��u�x�͵#�R;[��t���y�(���D�l��:���ҾzvIv�H�ݷ�$�KO�F��"z����J�"A�>�B.Gz�X�[!���3M�T�N���<�� d���#�aP����	16����+��=�l!��u;�S��.RL��ce�<�8s&��w���5h>�f(�A3�&�on;��s)d��'㿣Q�[������P�_ɬ��Y���CD���RH�G��U��o^3�p R:��B�&] B|����x'lݻ0-���Q"�U�jm����[���R��Ǻ>i���������W��9��v��`3)-/����̚��C���� 97���K�a,��&�~TFx9�z�H�C�����l�]`*OW��y�u��=ـέ�+n�����ʦe��Au�_�Zn��nb��lmPC�'�w����!�N�l��	90�t�4��ӫ{F�5fHē���J�͚���	��n8��r�������d�T� �'�@~w!������?��?��~���!f�A�Ə:�;�NQ�ǣ����pN����$ ��(�������l�9�c�%E}��P �w�0YFd�GR)0lZ>��`��#bk��>-�T�	����,���+R���^#ߠn�"��u�Qv�?^��B���ʽz����\Nw���%�!h�$�mwri���!_>���F����(�1��g�9(��J��n�x�g��~�1�CS��v�&4�sH�"#��qm�ѕ�+�X���M��y���Z�S�Qn���@uE�m(	Q�"����BN�����8L��8�	(�R���bR�Re!R�Z� �rR�d�;�M�F� ^l��'@2�p	��*��N��hY��I�R���8�7��Pg�悐;�B
m���j� ��@ iV�)o���Ctj�|&�
Y&$��4|aV)<������ �v�' +���<W#�g�T���'̗�����'(t��'��_� E���B�3��[�F �-�Z��`���WL>fO��1e�(�g<E����������b��/ƅ��������0^�]v�#?ME��W�N;5 �~����ːi����;���ҙ2���BD�A'wP5�W�����\�k�k\�O�}��D7�bs��1;d���`��ad�z#R��]wc��`�k����í����<����|�_��,����I̛����,��ox�'�'��$)���^0��-�y�ݷ����������f�ab����q�(
����+����Z]T6�X��D!��#1&&j���@1!%|-�!	�IZ��o��|�L^�W���;�����16DV��"��ʣ�W&e�i9��^���?2+�l���}��oƉ��7�}3�ò��閎���+���V���?�*{�0��Y�y��Zy���v��)!m��8?�����S��w�j�މ����(�����Ý���1�W�_�������},vأ�:q54�=�2u�(rʰ��:�4�=��Ź���:�=ZFx|8����K�>4�������(��`ڐ�8���C���\��\6��+�����r���TJVR��Kʍ\I.���a�y_�$����ffZz��j�v͓��)���=�<��)ȭm��f��|��0�9�K�F����Z�fm[oע�\x�9˞�U/O��q���~k(��{,������vE~�a���v�r�qO^7���I��,���l'-C'_���[c�=���T
���+��|%��Wr�I;�i� ��qt���v/U<N�ۙޫ��y���Gj�J�w�BֆG']�-u�+��|����,_xkT���˜􏏤S��pZ;���I�bȽ�Q���#I�ma�˒�����}���Z%y�[2��N�?l��bBnd�S)�{/�#s99��n�%��v�\��{�x�v�{t*9�4n��R�Ur��k��R�~w��,T˚&��'�N/�Q(�sv^=(�N�L���=�T�{yY�}��UӽL2�+�>�i��<i�R>)�72�,�S6����[�Ԯ�K���Ɠ�d�a��Z����Nk@��[\*�k�+i�r7/�Ú�L�\C�g��\1%ڻ��[#�i|�U�����Q"�4N���9	���j�0�M��F�Q�vcf�𪯚Y3Ӂ�\/����������~JLĻj�Z���t�g
�)j�^^^�#��/{���ӌ��1������x���l��c���H�1���i:7����B�#��y��y�㧮���3�����O��������n���1M}��s�;xM�oZ���\�Xlp\�����5�HBk�b���}��+�Qa�H׻z6����n��&6�R�\��)�X-�:�j�<S���b;���k��[�~�$������Ꮀ�5R�#�j�ne_@T�H�����;�Q2�4���p�Z�O��������=����Ea��		Y���?���Mb����y�$f^���Eb����y$f^����=b����y�#f�o�\�}�1}w���������[|2�ϭ}�/�����	�����A����˥��_����w|�.%�6^Z.*�bC��x��d�UXɾʟ5܈ͣW�<hG3�~�$�oe��N^���R�i��y��ww�Z�������Z�K�t�F%�rck+��MJ��[�����[1�>��[�g����o)�|��b�	H���E��s�<�eu�@�uP"i6(!:.�0�D��_����ބ������M0z��È��L���"P���͂H��fh4b֬���ѵ,Іl���~�*0L�>��>E
�C^J}��	=����}}�� i�5c�ki�}�&�r)���+W�A�f�������W�`ꁤ���^F�cڎ�nq���@��֣�D6?�H�P��?��m�c#w2<����ѯ��G�4风�o�A��ޣ���w��"�!D"��u�7]˧�-ԮE�U�<���*���A�L��ZA�����=m�(�th�����e�>aH�\��!���5`��'�mzo�:=�BW}}{2�q <-���݋g�Ҥ�O~�J�u`C����B:=���mf��x�O��?����+���#wۇ-hb���TzEHpH�T�/�']�Y�zG'�9�b7{qT��2�y#�򒽑��n��ֆ���B�����%:I���\C	���sX��Ez?�`C;0�N�~�4q���:E��\s�ëJ��1�'�R#:��
���� ���=K�#IV3������{�C�.����v;3���ؖ6ә����7].�C)Ng9�t9�N�Ҡ怐va�EZ�\7ܐ�WX�eB�q��7���]�O�tՌ4�����x�{��x�^��"7����,M��_�s	(���P�,w�m���4F�9��JУIi��ODl���\1�>@�xRH��R�iYC��j�C�wՇ^-2��5;�� �����.a/=W�H�?@�>�����+F��ƪ��Ђ������\W@��Lg�������x����7"�C3��J�f�N`*�9�^�M��-g���Y��
�.��T�!lot�/��ƻ��PQs��v]#��:�X�i �"7�9���{˶�{+A��}?N�k�ܭ���~�1������Ǡ��&7GNm��)���
ek\R�͎i,�*��c�x���z����@�l����C��@BۏQ�۸x�O�����?Mw�?n%aē���?����濴����_���O�Ќ���|�����o���~H`��l��ƽ_��+�~�ފ�
��!�����R�d6�j.��j&�ш�Led5I�4��e"��RJ��4*�$I��l�T����cbo����ѷN��O~�ǟ��­}J����Nb��c��c�����M���+
;�7oƾ����~#��7�� ��ƃ���}Mh�c�~?����?��~ַo���+��.�o�kpm\�7ز\d��=�,�Je��]��]?Oj�F��O��:Ʈ{w\c����(^���}g�)cy��A���]��
.���hR8�.��%��$����a&��E~E�����H����\�Ϲ��YLz��R���u4�V�\BCH��qy ����΅��-����`���Eet��vW.�g]2�M�-��q��I�E�.x��jl� �t�a�á�ǯ�Kf�VN�J��z�㊧݉}@���o��65�.�ʍN��7����P��[ĩ;׊�v�R�/p���l�u�QJ04X{�8�,�/���nc
��e]TX�
�]ޭ��	�So�8^o�E�1O36��H�����t:�ze�X����Y�Jw<�&��m��	@6i^�/�'	�}�0]��[�&��3*��tO��򶪰��Ae���⑩���4��N�.���|"����N��&rX�/d�V₻�p)5����|��J��c/�J4{������PZ,;{����G"��1'+"]��p��/ϊ�;k\��XaP�|у�L�Խ����칞�ɺ%� e���r�z���Ѡ���gc�Y̔g�CV�zD5��^Gl+'Ks^�\�DUY%mR8*��)�>�*��T��j�~4%Hk�ZR�j�/?X �E�dz���ӹ.a�6W���j�m�J5�>Y���Q���4N�s�O�.�S��͸B.���Sn�fڬ[w;z�XRI��%�a���*zΚ�ҐԸb���H�{��T�c*�g����Ϗ��􈻀������ﻱ_��b�ؽ�+�ߗ���U�z����
�����kV#|!�=��^n�P�4�e���k������[	�\¿�I�������q�b�@_^��{!��y�b��-ʊ��ؿ}�\r�~����|?����߿~��q)+�� +S�����&�Sg:�*�i�վrF�K����n2?Onӽ�<��r.Iq.�:Z� �g����h�Q΅y���r�Ϻ\g�	L;��5�|�
U��H����gւC`��7���*5�Q(ef�|���N�Zᤁ���Tg~��FD�6�y�[�3Fx�g�4�ɚbO����h;�﬎F��n��Ed]�H�k��"�Ĳ�8�	��e�.�Y����̴��TVoL��dn52:�t�_���e2�T�NZ,�n�e:4���lCP���2m�Ƒ�֏�2!ڣ�!���Q&5<�B�)9ѰGö�`@	��fNp����Āk�������J�?)�
/���t�gË􁇿u)�䡢,��r�[N�|{�f�
���l}6h�����s��m���_�V�+�0P��Qu�G,�*&uĊ\R`���	����eմ@��a�{x�UrǮK��cH�?��~���W�s�(^M�c�-䪜\���mt
ug�Kf�R'�E[�U{lc<ni�Jbo�1��Y�l
c����Q/G���i���㬑?&zU:��V�g��-Ю�(s���h�=����7\ޢ��h!P�ި�x�PZ�u�?��t�`O'(:F2�S�P���Q� �~@��@9�ֵb�P+�:C��N�r+3/cL�ϻ#�'p�E�)��Y1�-���a�d�\��+��p�܀�q'�|����U��3��u)MTE(H�kA"T��d|ddf�c*�@J
g�WfoW�Xn��ɢ�&v�#��"a�]�&&�Z�P�H`;�&T���E����Vy�l����d�N��:�թ�3�rS��'\ަ�2;�5Z�Nr�=qBH&�ku�	�q*D5m���᠘4W�������J��
,�(;J�]銧�=�q:^��F4������D�A�h�Ba��PJ	%q���!��e=U��bFP�a����QnQ��#,e��FX�=��d�vBb�֢�Ϥ��
Lz�4Vx�K�)s)�zJ'ת�f����B�4��K?�}�"z��c�EU���W��\��W�������uѦf;Sû��
>�U���i�6�g���h��c�`/ۖi�Eb?�H�2h+-�F��{��O�>%�~�4��6�*#z��b_����D�=�|�}��w��i������ބ.�J��{��%�c�6u ��j��,3�#��8Xɑ�
-t�9����� }#,�c���C��T�m͎Q��۾�S�*yt<w/���=�￻�y�5���=�����/J�������?)2uw�w�f��4z�9'�~<��zg�~_C~�7,�/�62������(��A��[���d�'�Tirn��h<l�5h�g����=.D�>���M��|[��ك[�x`��΀��ݏ�a=�
{��F�ͺq4��O{¯�k��*g/[ς��ŰUߐ3鉘�����nX,�p��D�^{z@Go
�[�I��f?B����A�o"�zX2�c,h��YB�"��TC�@Тg
-F������oMs`���-�4��1>C!���*�?:��y'n������YpPаˇg �Wg�|�3'������Z�VY��i��C�G��v��;q�݅=�.�?�`�P���F��mc�WO�>֑Q�\3�	2��scj���a��}ع4���FjDP�,FL��5��l�� ��4�mE�ɋ�9���?4?��6��;!0�~|3���<Mg+VN�C@��։}H3�2.C�Eߓ�	@ݰ>5Ɗ1���x�N`�&�^T��R.'�/�^Ht̀]2�W�at婇��>��XXS��`�þ���
��z`��\��D��א���e��׿~1&(l�l���>�E�o������Zcߢu+P������-Ȍ��CC���4ςx�?cؼ%p����>�oN�py��U�π.�5��9z��
��	�O�q��mɫfM��	C���5�LdٺV�nF�x�R��C��
?;<3Π��]�T*�/��q`C=��{�jz����Cd��p(���gv�7� �xm�[�5%<������N1��1��_i�<�ٰ��d8A�Ad@E��a]'z�'�M�� �Ycgj�����t�F�e @��`lHi��Q�ّ�0F�Ѯ ؉6��@��H�s�>����F�`�g@��f��&ٛ� �l�2,#�X�goe���kSC2���u�{�fq~�e��\6.0��Ց��luo~x����A6P��0����ƃV#A�~�� * �� �����#�zB(���3r �d?�23��P<��xw`�L\�> G����Ď ��DnE����(n��r6u���-6M���8�����9r�)���|�(��/z݂��c����t(�)x��1�w>q�u����t��MM��3�-1�c�#
���q�!��۵#��Ŏ���~[�?�|�w6�٥m\���ʐ��d:yw�w���|� 
���숹��JL}�
�a�Ȇg�κ@3M>���ad�'	�Q;��8��b�krM�[� vt{�Z���W���z�z^��:��֎D���ORi��$���HM��Z���}E������D�I��T��ϥ�T*�IdZ�mфA�y��F���l�<?��J0������4��#���<zaW�:�N�s�-�$���4%ɲ���xF�T��R
.�$IJ�S9-�g�Y-)�*!$%�LfsZ*�RZ�����^��}�s���^x�9��FZd�?{�_EJ�_u4���)��wr��ܵ/�YG�K(֯q5��5Y�	���U�&]9�Ԋ<Q5y��_�o�\�f�&�j=��v��[���['�j�t�I����ܟ�`�A��Ъ�����e�a��3]�!��	F�*��`Gv��ә�5q����TI�3���ή�&�*v:�2z������Y4�k��3�a;�N��V�g����d7�_p�r>��JW��|��A$/���q��[����K4_���uI�&X�i7�
�\������d66��D��N̥ib:���c;���&l�`䅧GѲ��3��hi�ol- ��j-1_���q�;�� F�$ �����F7H�;�<[�z��X:K3��!���c��nK����O�i�nqO��L����v��2�����	R`uUާr��s%��oK(Ga�#�Л�'}ɴ�sH��\$o�<��C$��ĩ�O�W�|�l6��vS��:_�]��d7[A�tU�hc�>^_�<j��(�Q����_�bv���8[+�o��;������v�TX)1��Q�1���m?��������g����p�.��m�Ϲ�gitGϼ�I��������s_�3<�:�$ө��������Mg��w��o#�<�;��H�	}�n!���_����;�+����I���T&u��o#��G?Ͽ����+�n��_��ھ���������;4wh�<�<W4_4I?S�R�Ԏ�_w�߭����45'�]`_óx?�U	�;R���$�h���2YB��Y<�O*I*��3��&�F�HI9�o
;���˰�O��3�_�.�׭����&��ٻ��DѮ{ϯ��Χ����"�"���� Q�׿�t�gZg�Nw���u�Jeң���������럋Eko�x�&z����^�Ѯ����9�e��<>)����a��=�)~�aJwv���<qctjΉW�l�����9XK����V�h<:,��4&1><M�x+-wh"���Ͽ����h���}�x����u���������M�{�����U�*������_���?�����ѷ���?5��mR���S���v���{��%h �?�����%�������?���?�_���O9���)��P����'E0���@��
�U�pU'\��K�p�����0�Q	����� �������n���"4��a?�4������O�+�k��y���͟��r�,9�i�I��t�r
�~���e�3���e�Ӿ�~"?��y��w�w�~�V?���~E��fVQ����|Y�D�&�33Q��묥�Z�"n��������ya�g�L���X���K�$̅��gNF���G�e�m�,|_����a�?H/���>_�>�����xy�g3%��r����� n�.�)ŜLu�^���z�������.��8�\�yJ��ș��l�}�9��%e�@��Z�Ijg��x����#�����g��9_4u�
b.tn�Y��f4B�A��64@�=-��P�����������,�����ш��A��W���'����z���� �W���8���� �������������������?���	�?��ׇW���k�����3a��Y.,B��$2Nj����v�����u����p'�.�sY�����Ύm)3�8�~N#)ѣ�����F�£ۜ�����;�ذZ�����F.���m��	��3�����lG�a�J�T�#��CA���^y�	�tA(��~%Jf�������K��m|��G��4*&�%�h$�٧Uo��PN��l��g�A4H�@;*��,!��d��G)Qs�'&�����&���tqi>��13���74B�����
4@���K����� ����M����S���+A����q6X��<�|Ns�Oq4F�b!�s>\��1l@�~���$O�X��ߏ&������������ʾ��α��6j0H�f��P���F�[����t��K���qsk{�F˓�,�c��͹H�#.�:�l�w��yh��m��lI���e�˲�b�K����Q'?nGg՛w!���h��������?O��[+�p�C�W��0�S������2��7��	��_}�����0��)��v����тv<��%خ\w�V��Ǘ�O��@K��YϸdL����G��YVH�٥�u����4N�쌭�%)���ز�ɦ`�,NLE�4
�}����h��O��[p����w|o4a�����������?����@ցF�?�����
������"�k��0��$x�q3e�gWb�<�����j��/��K�{;ʐ��Z�� ��7� �z�� W�t�I�*U�v	��w �i�R#G�V?OI�L��[��2l�QQ�j��]Y�<�He@�"c4��TP�-�6z�/�s��W�fV��o7��
$r��n}y	�����+�� 0��X��8�����Vo�0`@xB��ahtNcQ�9���P,7H�r�1�� 3(G�t)z�@0ͥ.���VLܩZ<~Ԅ������i tŔTe�a��k����+�5�i]1�gY�o��Y��cj��}!W!��V:�/�I�I�.5����+��h��䲶{�~!4{Ѡ	���?
�_���?�`£����������?h���*���>�����W�J�2�����;��i����
@�?��C�?��כ����M�D���3���>Fq;��8R���1Ň,�1\Hz��v�GĜ�C�q��BX��04��0��T����x���_w�ץ�s��f��B�>1�Y6
ji��T�:��t�e����t)Ëe��JO�j�Ŏ�.wj#d�!��.��� #��9�L.c*]e���]�q�?9H<��� #7m��}+�p��ԃ����������_%��P�������U������0�W��o��!㽉 �����	�������P9��/�����*����w��
���~�����o�8؎��e���K:e�TY'���wP�2�-����BK�Gf�o�C~d����F�u��(&�d�{Zxܩ]����Α�΢�w�g���i���x�MVt��Kd2�{bw�_O�l2r3O��7���Y�uw���f�|8b\J�t�B[ٶ�����z��s����v#������zGVTE9���B��w+To08`R��c�Gw)�;�OeG��8�jJT��")�޷g!�y%OOxt�u[��ҡ��8Ř?Is4R#�֘tc�.�*;OQ�g�2�ݡ�������pFB�ǲ+C��U����5����7P�n���'p�_kB����MC������ �a��a�����>N��I@#����M���ׇ����Kp��F���	��* ��������[o����7��
|���n����	x�*��{���J��'0��'���@U��x������_?����u�f��p����_;���?@�W��?�C�������~p��T�f�?�CT����{�(���� ����K�p����;��?*B�l����?��k��w����A�k!5�	�����*�?@��?@���A�դ� �F@����_#�����Y��U������*�?@��?@�C���������/�#��P�n����l������J�(�����ф��������?����%�����p�U��o^�<=�P�� ��?��k���|�����$������e���q��sOdx%��{X@RX����>�z�Q���Q���M������	���#u|���OSf/��{�8��@�Vx7o�4#S�~_����� �@c>��$INI[�r��[�	�$��I�L��tg]�=�m�cj#%i�#����9�/t;	ig�%:q$-'['M���	/P�9^�r���M(��T���vw/��7�ah��������?O��[+�p�C�W��0�S������2��7��	��_}����0 u���v�nm�����Pꮆ�rԹ��m|x�/�N�z_�?;\���J��-�8��<N����.1�8�<5
�����Qgv�èS.g�sG���<����ԣ�߮�K�6��{+�q�����oEh��x����Є�/������_���_�������X�����������)����{阔&ҁ�ZS3[�812��\���������M�ɢ+�|��@�-���;;@[�i�����v~�uq
���~��l�,�w�ф�F5тQ����P�9�_��a\�~�쨒l���NZ ��n}y�oO�N����N[,t��Y8�����w�JБW��'t�(�F�4e������r���i2�r��~Y tŔ�.{��=/����өO��\�=�4F6���]X�#���׮&Ģ:��I|���T���:�[s^ �hםҭ�'��b��ٽ���wW��?=��÷G������1��o%���������I���_	�P��ԃ�O��������#^�E������p��
4��	���R��U�����L��*�����[���r�U�5�ϰ%I�_����ic�Ә=�8/��K���:p�/�����,X/��m�4-:ώ�|�U/��y�z�x�������b�!_=?�P�/=�"�ֺ�t1z�.G7���\�RK��ƖLl����Ӫ�_]W]��@��ے�34i�ʘ�*Ȑ֒�F�J[�)�;���F�R���%o���>n0���e�LJ�x��\R�+��0xn�rOVޓ���^ڹ���b4Sn_�0|�������2��.=}&�rdƢ$�Nf�ɖh�e��(�f�;�]�n�B��d�Qz���e��� ���Ĳ[��GT�6��������tʟ��i�P	A�xj�"5c���:ϰ���]dιYb���Tr�]7���@N�������������oE�F��>��Nz>��p������������b��/<�������q/�|���&���������*�Ϝ���h!t���c?�1Dq�����1�}fH��9�t������\��ZA�#Wnj��ߊ�����������_h���Y�^���W	*����������1��4�J���/o�����Ss�4��X������)3_w��gW��E��@�R�O���`C������C~���Y����.:/�����{�����~&�V�K��e����Z�n�W&�3Cjr���7L�g�V���n�-F�6~d�N��]JȸŤ�nڽ(Vw����C�����~����r�ł�贤q�es���5:_�Y�J�A��KAC�~B</�������l�8f�S�ZO�%�h5���)D��V�$;,3��.�m����垶����Qh�ꉅ.*�\��������G�?��[	*8�i�	� d8��G��_�\���0\�>�����;�&5�5��ϧprR�Δ'- ��=U����~����"����wh�t'��Nv�Ŏ�*�E@y���w��o1b_0+4��?C��E��{C��������X�����3���*��d�lH�V=��ء,N�U-����W��!r�#U����%q-؏���{-o}�'~���%����Y��ۻ�8��4H��ג�_X�1��������������\��2CZ����?�U�ϒ��·������i���D-(�`�i��u�To�n޽��������\�?Կ\�Q:q�˺��us~)��} �q�/�ɱ������\m���s�O�EÅX��\a?:tu����\p���k�i��V����^��:'�xZ���I�pok�v�MN䠿k������f��_����3G'iY�0�[7�i�]O��hێ��ܒ#,��i�cz�m���%�L��E������B���y�g��H�p�h}h��Ӧ[��������|[��a�����d�qU����Q�\C�Ռq�m�ӡ�VG��`�j�ݫ_��h�m��z�v���ٕ>U������"��e��({�9�Tq'�B�ޔ�ӯ\��O��G�Z����B���A�U ��o������Б���D�쑉��z�'[���T���0����O���V��c8td�����eA�a�)�?���������?������oP��A�w�o���W�B}���H�������!�O�L�?{U���D:�5�Z�� ���^�o�����T@��I� �s@�A���?I\�����R��C]����#����/�dD��."������?��H�� ������	��������T@�� )=�߷�˄���?����Ȃ�CF:2�_��p���P��?@��� ������P=�߷�˄���?22��P�����?��?������P��?���Q��R����#�������F����
������L��0�0�������%�g`�(���<��7!�G��������E�*���R"�o0$A��^bg�f�)�ef�U&Mʰ��U,ѦɖL ò��o�)/�l���c�V?�_�,�����a�:����]e�E��8���r��E��7d���{��_��ǑX�e<Ғ��N�f���dN�"^я}a��R���W#ٲV!���p��¼�%����k��$yT'�<�緃RP��ڡE�%�̙J����T����ƨӶ%1d���nq�z[��K�uTj�~y�W<�y���N
��Yh���':P���
F}�@���Б���?�@���|��@�W�~ɂ�C������� ��m��Ǳ��売a���i۫IK`w���ٓ�%����ek�l��k��7]|+��ĸ������#�WŒ����f�h�5k0S5^��P^ζu�j3r)�v�.�)� �{-�h���������=��xQ�Bdb��!� �� ����!����L�?���E�i���������ZM;�%/�7Z��Y�{����?i�����!Vx��ʄ�/�/| ?���{����
�76�Q��q�՛��ݼ�ی4}8k��8ϖx�0ʏ�h�߲nͰS~�cK���v׺䶱�f^Q�h�J)��6-�z��68��������R�6n���z��5�>o��1*�i
ф�;�j�W�G/�?'(Ql�|��憨V8�~��{i���O�=��9"Gp�S���.AtdCj�2�ѭ�?7�ue�E�?;LJ�(`�T:� ���؎�k�T�5�tyw`��eȸ֪4����=�K����?������d��������?�j�G�M��a��ۓ	�go����i���?=xY��������������A�� ��'I`�/�����\���?���
����"ਯ�=���\���?`�o*dI��
d�����W�1�
������P��~Ʉ�#n����K��V�D
�����2����22����#2�3���8���7�?NI��������}�8|��"�33˸��������y�����܏$������c�G�a؟��HR?�W�������ۺ��^�7����v�Nثv�!U�#0j��Mi���L��k��h�ָ�O�yg���Nmn0���M#��(<L).(Y��x-���x�0I��~4���������t�vx�`;�����0ϲ�&o��b������G�2Y��v;�s��q��:џ��!���1K-�-A��8�:�z9��ﵡ�Vt*Q��9�Vf~�w�#e�RCi�z������td����?2�������������2��0���,���C�H�L��7��0��
P��A�/���6��`�����"�/�]��}��L�?���#"C�����d"������V�_�$��_�T��M�:���ʥ�ڴ��������>�E�}�h�uwe���K��� `O���P�[��?�Tۭi�VR*�Q`؍�N�^��P�I�\/t��3����M���IН7��y�4�C��D���3e���� `I�����$�?��F\��{T[��e��:���+�b67e�U�ٖd~.����e�#(<��M�7P��I84�ה��(̣�4u���֘�4#}���a��	�G�X���r��ip�W�>�����_��Hܨ�X�O���?U�XC+���h�V.i欈�E�:C�MZ$���&M���eц���Y.��a>o����ɂ��Z������\���NٞC�%�>�z�	���O45b1�����R��dN�r����1܌�Bmo���D?��ީ����j��KZ��]Դ�~?S�S�!�Ӡ���AO�Q�0�Ƣe���6��cX��d������@��'�@�� wN���Б	���?�@��O� �a �Kq�dA�!�C�ό���n5�/$�-�|a�c��F�����Pj��I��#'�l/����v�ߒ��U�Z}�R���ڈƼ����/Y�J��c�=�u�SͰ%��D��^m︎V�5>�	��k�F�5��N�@��� o� FH&�A�2 �� ��������hȂ���"�?D|����g���>7<f���V���Q8���Ք�{������r ��B /s �K;�i+�	������U+
���j���r.��r���S[��bZb�#���~�.��|y`�h�^3�@իDi�on[�j!����6K|�qQ������sUjф�;�*%}���u5�/��[	&!����A�+�d7�jIT�p�[֦c���]��#L=����Ql�~��YN���p�ύ�D�~ڶx����y�y]\j��Z5��l�P>�sw���;���i��M�ح}��Qm���Q�sfO��bmH�s�V�ڝ�`Bu�⤌���w��|�}�f��um�7��b�����SdA���ܜۦ�������O��o�7�Gm+����aN���"|$�c��W{�U����C���������~9��U��	� �a��]ȯ6�2������>oГ�Ga������J�����^��8?�bs��J%w���L6o�7��r���㖇`�}���?�!����'I6����{���q��1�o9�������?s��o��<�qÜ�Z%w�Zsg��a��S1Cӈ7Ƿ��<��&�u��o�ڹ�:�����=˾��¹�3v�o���9~���*J��w���3f��x��߽�7���{�AW��������]���y�,~�;�����,��^?�չV��x߿�{n�>��q����?a7;/�a��h�ŗ������3��9�M?w�sr�&�x#�/s\C�w���W9�E�X����:��[�J�����9A�3s�ko��u��JCl����J�Orwk���3��&��߷^�;�L�������Zz�����|��1�F�3M��6�2�|����q�ŇM�F��_,N�����.��Q�?_�¥���������!�W��I<|v�ߘ��ۢ���赅VSR����� �\�]���y��/?)y��W]�Er��/O���C-                 ���A�7� � 