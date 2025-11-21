import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/core/l10n/l10n_extension.dart';
import 'package:suefery_partner/presentation/auth/auth_cubit.dart';

import 'store_setup_cubit.dart';

class StoreSetupScreen extends StatelessWidget {
  const StoreSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the localized Cubit just for this screen
    return BlocProvider(
      create: (_) => StoreSetupCubit(),
      child: const _StoreSetupView(),
    );
  }
}

class _StoreSetupView extends StatelessWidget {
  const _StoreSetupView();

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    final theme = Theme.of(context);
    final authCubit = context.read<AuthCubit>();
    final setupCubit = context.read<StoreSetupCubit>();
    
    // We use a local controller for the tag input field
    final tagController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text(strings.setupTitle)),
      body: BlocConsumer<StoreSetupCubit, StoreSetupState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Stepper(
            type: StepperType.horizontal,
            currentStep: state.currentStep,
            onStepContinue: () {
              final isReady = setupCubit.nextStep();
              
              // If we are on the last step (index 2) AND validation passed
              if (isReady && state.currentStep == 2) {
                 if (setupCubit.validateSubmission()) {
                    // Trigger the API call in AuthCubit
                    authCubit.completeSetup(
                      storeName: state.storeName,
                      bio: state.bio,
                      website: state.website,
                      address: state.address,
                      city: state.city,
                      tags: state.tags,
                      lat: state.lat,
                      lng: state.lng,
                    );
                 }
              }
            },
            onStepCancel: setupCubit.previousStep,
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: details.onStepContinue,
                        child: Text(state.currentStep == 2 ? strings.completeSetup : strings.next),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (state.currentStep > 0)
                      Expanded(
                        child: TextButton(
                          onPressed: details.onStepCancel,
                          child: Text(strings.back),
                        ),
                      ),
                  ],
                ),
              );
            },
            steps: [
              // STEP 1: INFO
              Step(
                title: Text(strings.stepInfo),
                isActive: state.currentStep >= 0,
                state: state.currentStep > 0 ? StepState.complete : StepState.indexed,
                content: Column(
                  children: [
                    Text(strings.oneLastStep, 
                      style: theme.textTheme.headlineSmall?.copyWith(color: theme.primaryColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(strings.setupSubtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                    
                    TextFormField(
                      initialValue: state.storeName,
                      decoration: InputDecoration(labelText: strings.storeName, prefixIcon: const Icon(Icons.store)),
                      onChanged: setupCubit.storeNameChanged,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: state.bio,
                      decoration: InputDecoration(labelText: strings.bioLabel, prefixIcon: const Icon(Icons.info_outline)),
                      onChanged: setupCubit.bioChanged,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: state.website,
                      decoration: InputDecoration(labelText: strings.websiteLabel, prefixIcon: const Icon(Icons.web)),
                      onChanged: setupCubit.websiteChanged,
                    ),
                  ],
                ),
              ),

              // STEP 2: LOCATION
              Step(
                title: Text(strings.stepLocation),
                isActive: state.currentStep >= 1,
                state: state.currentStep > 1 ? StepState.complete : StepState.indexed,
                content: Column(
                  children: [
                    TextFormField(
                      initialValue: state.address,
                      decoration: InputDecoration(labelText: strings.addressLabel, prefixIcon: const Icon(Icons.location_on)),
                      onChanged: setupCubit.addressChanged,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: state.city,
                      decoration: InputDecoration(labelText: strings.cityLabel, prefixIcon: const Icon(Icons.map)),
                      onChanged: setupCubit.cityChanged,
                    ),
                    const SizedBox(height: 20),
                    Text(strings.coordsLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: state.lat.toString(),
                            decoration: const InputDecoration(labelText: "Lat"),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: setupCubit.latChanged,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            initialValue: state.lng.toString(),
                            decoration: const InputDecoration(labelText: "Lng"),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: setupCubit.lngChanged,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(strings.coordTip, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),

              // STEP 3: TAGS
              Step(
                title: Text(strings.stepTags),
                isActive: state.currentStep >= 2,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.tagsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(strings.tagsSubtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tagController,
                            decoration: InputDecoration(hintText: strings.addTagHint, isDense: true),
                            onSubmitted: (val) {
                              setupCubit.addTag(val);
                              tagController.clear();
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          onPressed: () {
                            setupCubit.addTag(tagController.text);
                            tagController.clear();
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      children: state.tags.map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () => setupCubit.removeTag(tag),
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                      )).toList(),
                    ),
                    if (state.tags.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(strings.noTags, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}