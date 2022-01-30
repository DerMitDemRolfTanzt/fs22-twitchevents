/*
MIT License

Copyright (c) 2022 DerMitDemRolfTanzt

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Xml;
using ConnectorLib;
using CrowdControl.Common;
using JetBrains.Annotations;
using ConnectorType = CrowdControl.Common.ConnectorType;

namespace CrowdControl.Games.Packs
{
    public enum Method {
        StartEffect,
        StopEffect,
    }

    public class FS22EffectPack : PCEffectPack<NullConnector>
    {
        private const bool debug = false;

        private const string ccEffectPackVersion = "0.2.0";
        private const string xmlSchemaVersion = "0.1.0";

        private static readonly string connectorPath = Path.Join(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "My Games/FarmingSimulator2022/twitchEvents/connector");
        private static readonly string xmlPathIn = Path.Join(connectorPath, "in.xml");
        private static readonly string xmlPathOut = Path.Join(connectorPath, "out.xml");

        // First argument is an effect pack index assigned internally by Warp World for official effect packs.
        // We can use any integer here since it's ignored for any SDK/ccpak plugin.
        public override Game Game { get; } = new Game(7522, "Farming Simulator 22", "FS22EffectPack", "PC", ConnectorType.NullConnector);

        public FS22EffectPack([NotNull] IPlayer player, [NotNull] Func<CrowdControlBlock, bool> responseHandler, [NotNull] Action<object> statusUpdateHandler)
            : base(player, responseHandler, statusUpdateHandler)
        {
            Directory.CreateDirectory(connectorPath);
        }

        #region debug

        protected string GetFields(Type t, string separator = "", BindingFlags flags = BindingFlags.Public|BindingFlags.NonPublic|BindingFlags.Instance|BindingFlags.DeclaredOnly) {
            return String.Join(separator, t.GetFields(flags).ToList().Select(field => $"<Field>{field}</Field>"));
        }

        protected string GetProperties(Type t, string separator = "", BindingFlags flags = BindingFlags.Public|BindingFlags.NonPublic|BindingFlags.Instance|BindingFlags.DeclaredOnly) {
            return String.Join(separator, t.GetProperties(flags).ToList().Select(property => $"<Property>{property}</Property>"));
        }

        protected string GetMethods(Type t, string separator = "", BindingFlags flags = BindingFlags.Public|BindingFlags.NonPublic|BindingFlags.Instance|BindingFlags.DeclaredOnly) {
            return String.Join(separator, t.GetMethods(flags).ToList().Select(method => $"<Method>{method}</Method>"));
        }

        protected string GetConstructors(Type t, string separator = "", BindingFlags flags = BindingFlags.Public|BindingFlags.NonPublic|BindingFlags.Instance|BindingFlags.DeclaredOnly) {
            return String.Join(separator, t.GetConstructors(flags).ToList().Select(constructor => $"<Constructor>{constructor}</Constructor>"));
        }

        protected string GetConnectorTypes() {
            var q = AppDomain.CurrentDomain.GetAssemblies()
                       .SelectMany(t => t.GetTypes())
                       .Where(t => t.Name.Contains("EffectPack"));
            return String.Join("\n        ", q.ToList().Select( c => $"<ConnectorType><Namespace>{c.Namespace}</Namespace><Name>{c.Name}</Name><BaseType>{c.BaseType}</BaseType><Fields>{GetFields(c)}</Fields><Properties>{GetProperties(c)}</Properties><Methods>{GetMethods(c)}</Methods><Constructors>{GetConstructors(c)}</Constructors></ConnectorType>" ));
        }

        #endregion

        // Unfortunately the XML Assembly is not embedded to the CrowdControl SDK, therefore we need to write and parse XML manually.

        protected bool XmlWrite(EffectRequest request, Method method) {
            string parameterItems = String.Join("\n            ", request.ParameterItems.Select(i => $"<ParameterItem>{i.AsSimpleType}</ParameterItem>"));

            string debugConnectorTypes = !debug ? "" : $@"
<debug>
    <ConnectorTypes>
        {GetConnectorTypes()}
    </ConnectorTypes>
</debug>
            ";

            string debugRequest = !debug ? "" : $@"
            <debug>
                <type>{request.GetType()}</type>
                <properties>
                    {GetProperties(request.GetType(), "\n                ")}
                </properties>
                <fields>
                    {GetFields(request.GetType(), "\n                ")}
                </fields>
                <methods>
                    {GetMethods(request.GetType(), "\n                ")}
                </methods>
            </debug>
";

            string eventsXml = $@"{debugConnectorTypes}
<eventIndex>
    <xmlSchemaVersion>{xmlSchemaVersion}</xmlSchemaVersion>
    <events>
        <event>{debugRequest}
            <Method>{method}</Method>
            <InventoryItem>{request.InventoryItem}</InventoryItem>
            <ParameterItems>{parameterItems}</ParameterItems>
            <FormulaVariableType>{request.FormulaVariableType}</FormulaVariableType>
            <FinalCode>{request.FinalCode}</FinalCode>
            <BaseCode>{request.BaseCode}</BaseCode>
            <DisplayViewer>{request.DisplayViewer}</DisplayViewer>
            <Test>{request.Test}</Test>
            <Queued>{request.Queued}</Queued>
            <Elite>{request.Elite}</Elite>
            <Anonymous>{request.Anonymous}</Anonymous>
            <Cost>{request.Cost}</Cost>
            <ID>{request.ID}</ID>
            <Stamp>{request.Stamp}</Stamp>
            <BlockType>{request.BlockType}</BlockType>
        </event>
    </events>
</eventIndex>
";

            File.WriteAllText(xmlPathIn, eventsXml);

            return true;
        }

        protected bool XmlCheck(EffectRequest request, Method method) {
            if (!File.Exists(xmlPathOut)) {
                return false;
            }

            string outXml = File.ReadAllText(xmlPathOut);
            string eventIndexXml = Regex.Match(outXml, @"<eventIndex>\s*(.*)\s*<\/eventIndex>", RegexOptions.Singleline).Groups[1].Value;
            string eventsXml = Regex.Match(eventIndexXml, @"<events>\s*(.*)\s*<\/events>", RegexOptions.Singleline).Groups[1].Value;
            MatchCollection eventXmls = Regex.Matches(eventsXml, @"<event>\s*?(.*?)\s*?<\/event>", RegexOptions.Singleline);

            foreach (Match eventXmlMatch in eventXmls) {
                string eventXml = eventXmlMatch.Groups[1].Value;

                if (
                    Regex.IsMatch(eventXml, $@"<ID>\s*?{Regex.Escape(request.ID.ToString())}\s*?<\/ID>", RegexOptions.Singleline) &&
                    Regex.IsMatch(eventXml, $@"<executed>\s*?[Tt]rue\s*?<\/executed>", RegexOptions.Singleline)
                ) {
                    return true;
                }
            }
            return false;
        }

        protected bool XmlWait(EffectRequest request, Method method, int millisecondsTimeout = 5000, int millisecondsCheckInterval = 500) {
            return SpinWait.SpinUntil(() => {
                Thread.Sleep(millisecondsCheckInterval);
                return XmlCheck(request, method);
            }, millisecondsTimeout);
        }

        protected bool XmlDelete() {
            File.Delete(xmlPathIn);
            File.Delete(xmlPathOut);
            return true;
        }

        protected bool SendEffect(EffectRequest request, Method method) {
            XmlWrite(request, method);
            bool success = XmlWait(request, method);
            XmlDelete();
            return success;
        }

        #region Effect List
        public override List<Effect> Effects
        {
            get
            {
                List<Effect> result = new List<Effect>
                {
                    new Effect("Debug Message", "debug"),

                    new Effect("Visual Effects / Trolls", "visual", ItemKind.Folder),
                    new Effect("Invisible Vehicle", "invisiblevehicle", "visual"),
                    new Effect("Top Down Camera", "topdown", "visual"),
                    new Effect("Invert Controls", "invertcontrols", "visual"),
                    new Effect("Rotate Camera by 180 degrees", "upsidedown", "visual"),

                    new Effect("Vehicle condition", "vehiclecondition", ItemKind.Folder),
                    new Effect("Repair Vehicle by ... %", "repairvehicle", new[]{"percent"}, "vehiclecondition"),
                    new Effect("Damage Vehicle by ... %", "damagevehicle", new[]{"percent"}, "vehiclecondition"),
                };
                return result;
            }
        }

        public override List<ItemType> ItemTypes => new List<ItemType>(new[]
        {
            new ItemType("Percent", "percent", ItemType.Subtype.Slider, "{\"min\":1,\"max\":100}")
        });

        #endregion

        protected override bool IsReady(EffectRequest request)
        {
            //TODO: Implement
            return true;
        }

        protected override void StartEffect(EffectRequest request)
        {
            if (!IsReady(request))
            {
                DelayEffect(request);
                return;
            }

            TryEffect(request,
                () => true,
                () =>
                {
                    try
                    {
                        return SendEffect(request, Method.StartEffect);
                    }
                    catch { return false; }
                },
                () => Connector.SendMessage($"{request.DisplayViewer} invoked {request.InventoryItem}."),
                null, true, request.FinalCode);
        }

        protected override bool StopEffect(EffectRequest request)
        {
            return true;
        }

        protected override void RequestData(DataRequest request) => Respond(request, request.Key, null, false, $"Variable name \"{request.Key}\" not known.");
    }
}
