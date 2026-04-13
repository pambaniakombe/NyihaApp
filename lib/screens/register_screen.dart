import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';
import '../widgets/kente_strip.dart';
import '../widgets/nyiha_buttons.dart';

class _FieldDef {
  const _FieldDef({
    required this.id,
    required this.label,
    required this.type,
    this.placeholder,
    this.options,
  });

  final String id;
  final String label;
  final String type;
  final String? placeholder;
  final List<String>? options;
}

class _StepDef {
  const _StepDef({required this.label, required this.fields});

  final String label;
  final List<_FieldDef> fields;
}

const List<_StepDef> _regSteps = [
  _StepDef(
    label: 'Taarifa Binafsi',
    fields: [
      _FieldDef(id: 'r-name', label: 'Jina Kamili', type: 'text', placeholder: 'Mfano: Petro Mwakasege'),
      _FieldDef(
        id: 'r-marital',
        label: 'Hali ya Ndoa',
        type: 'select',
        options: ['Sijaoana', 'Nimeoa/Nimelolewa', 'Mjane/Mgane'],
      ),
      _FieldDef(id: 'r-children', label: 'Idadi ya Watoto', type: 'number', placeholder: '0'),
      _FieldDef(id: 'r-location', label: 'Makazi (Mji/Nchi)', type: 'text', placeholder: 'Dar es Salaam, Tanzania'),
    ],
  ),
  _StepDef(
    label: 'Familia',
    fields: [
      _FieldDef(id: 'r-father', label: 'Jina la Baba', type: 'text', placeholder: 'Jina la baba yako'),
      _FieldDef(id: 'r-mother', label: 'Jina la Mama', type: 'text', placeholder: 'Jina la mama yako'),
      _FieldDef(id: 'r-relatives', label: 'Jamaa wa Karibu', type: 'text', placeholder: 'Kaka, dada, shangazi...'),
      _FieldDef(id: 'r-rel-loc', label: 'Makazi ya Jamaa', type: 'text', placeholder: 'Wanaishi wapi?'),
    ],
  ),
  _StepDef(
    label: 'Akaunti',
    fields: [
      _FieldDef(id: 'r-phone', label: 'Nambari ya Simu', type: 'tel', placeholder: '+255 xxx xxx xxx'),
      _FieldDef(id: 'r-username', label: 'Jina la Mtumiaji', type: 'text', placeholder: 'nyiha_user'),
      _FieldDef(id: 'r-pass', label: 'Nenosiri', type: 'password', placeholder: 'Angalau herufi 8'),
      _FieldDef(id: 'r-pass2', label: 'Thibitisha Nenosiri', type: 'password', placeholder: 'Rudia nenosiri'),
    ],
  ),
  _StepDef(
    label: 'Picha & Uthibitisho',
    fields: [
      _FieldDef(id: 'r-photo', label: 'Picha ya Wasifu', type: 'text', placeholder: '(Itapigwa baadaye kwenye app)'),
      _FieldDef(id: 'r-referral', label: 'Aliyekupeleka (Hiari)', type: 'text', placeholder: 'Jina la mwanachama'),
    ],
  ),
];

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _ctrl(String id) {
    return _controllers.putIfAbsent(id, TextEditingController.new);
  }

  void _syncFromApp(AppState app) {
    for (final step in _regSteps) {
      for (final f in step.fields) {
        final v = app.regData[f.id];
        if (v != null && (_controllers[f.id]?.text.isEmpty ?? true)) {
          _controllers[f.id]?.text = v;
        }
      }
    }
  }

  void _saveStep(AppState app) {
    final step = _regSteps[app.regStep - 1];
    for (final f in step.fields) {
      app.saveRegField(f.id, _ctrl(f.id).text);
    }
  }

  InputDecoration _dec(BuildContext context, String? hint) {
    return InputDecoration(
      hintText: hint,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, app, _) {
        _syncFromApp(app);
        final step = _regSteps[app.regStep - 1];
        final progress = app.regStep / _regSteps.length;
        return Scaffold(
          body: Stack(
            children: [
              Container(width: double.infinity, height: double.infinity, decoration: NyihaDecorations.pageGradient(context)),
              Positioned.fill(child: DecoratedBox(decoration: NyihaDecorations.subtleRadialAccent(context))),
              Column(
                children: [
                  const KenteStrip(height: 5),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        IconButton(
                          onPressed: () => app.setScreen(AppScreen.onboarding),
                          icon: const Icon(Icons.arrow_back_rounded, color: NyihaColors.gold),
                          style: IconButton.styleFrom(backgroundColor: NyihaColors.gold.withOpacity(0.1)),
                        ),
                        const SizedBox(height: 8),
                        Text('Jiunge nasi', style: nyihaCinzel(context, size: 26)),
                        const SizedBox(height: 6),
                        Text(
                          'Hatua ${app.regStep} ya ${_regSteps.length}',
                          style: nyihaNunito(context, size: 13, color: NyihaColors.onSurfaceMuted(context)),
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: NyihaColors.gold.withOpacity(0.18),
                            color: NyihaColors.gold,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Hatua ${app.regStep}: ${step.label}',
                          style: nyihaCinzel(context, size: 17),
                        ),
                        const SizedBox(height: 20),
                        ...step.fields.map((f) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f.label.toUpperCase(), style: nyihaFieldLabel(context)),
                                const SizedBox(height: 4),
                                if (f.type == 'select')
                                  DropdownButtonFormField<String>(
                                    value: f.options!.contains(app.regData[f.id]) ? app.regData[f.id] : null,
                                    decoration: _dec(context, null),
                                    dropdownColor: Theme.of(context).brightness == Brightness.dark ? NyihaColors.earth850 : NyihaColors.ivory,
                                    hint: Text('Chagua...', style: TextStyle(color: NyihaColors.gold.withOpacity(0.5))),
                                    items: f.options!
                                        .map(
                                          (o) => DropdownMenuItem(
                                            value: o,
                                            child: Text(o, style: TextStyle(color: NyihaColors.onSurface(context))),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        app.saveRegField(f.id, v);
                                      }
                                    },
                                  )
                                else
                                  TextField(
                                    controller: _ctrl(f.id),
                                    obscureText: f.type == 'password',
                                    keyboardType: f.type == 'number'
                                        ? TextInputType.number
                                        : f.type == 'tel'
                                            ? TextInputType.phone
                                            : TextInputType.text,
                                    style: nyihaNunito(context, size: 14, color: NyihaColors.onSurface(context)),
                                    decoration: _dec(context, f.placeholder),
                                  ),
                              ],
                            ),
                          );
                        }),
                        Row(
                          children: [
                            if (app.regStep > 1)
                              Expanded(
                                child: BtnOutline(
                                  label: '← Nyuma',
                                  onPressed: () {
                                    _saveStep(app);
                                    app.setRegStep(app.regStep - 1);
                                  },
                                ),
                              ),
                            if (app.regStep > 1) const SizedBox(width: 12),
                            Expanded(
                              flex: app.regStep > 1 ? 1 : 1,
                              child: BtnGold(
                                label: app.regStep == _regSteps.length ? 'Maliza ✓' : 'Endelea →',
                                onPressed: () {
                                  _saveStep(app);
                                  if (app.regStep == _regSteps.length) {
                                    app.setScreen(AppScreen.terms);
                                  } else {
                                    app.setRegStep(app.regStep + 1);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        );
      },
    );
  }
}
